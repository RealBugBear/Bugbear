const { readFileSync } = require('fs');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-test',
    firestore: {
      rules: readFileSync('firestore.rules', 'utf8'),
    },
  });
});

afterAll(async () => await testEnv.cleanup());

function userDb(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function unauthDb() {
  return testEnv.unauthenticatedContext().firestore();
}

test('owner can CRUD their own profile document', async () => {
  const db = userDb('userA');
  const ref = db.doc('users/userA/profiles/profile1');

  await assertSucceeds(ref.set({ name: 'Alice' }));
  await assertSucceeds(ref.get());
  await assertSucceeds(ref.update({ age: 8 }));
  await assertSucceeds(ref.delete());
});

test('unauthenticated access is blocked everywhere', async () => {
  const db = unauthDb();

  await assertFails(db.doc('users/userA').get());
  await assertFails(db.collection('forum/posts').get());
  await assertFails(db.collection('reports').add({ reason: 'spam' }));
});

test('cross-user reads and writes are denied', async () => {
  const dbOwner = userDb('owner');
  const dbOther = userDb('intruder');
  const sessionRef = dbOwner.doc('users/owner/sessions/s1');

  await assertSucceeds(sessionRef.set({ when: '2025-09-01' }));
  await assertFails(dbOther.doc('users/owner/sessions/s1').get());
  await assertFails(
    dbOther.doc('users/owner/sessions/s1').set({ when: '2025-10-01' })
  );
});

test('forum rules allow authors but enforce payload validation', async () => {
  const db = userDb('poster');
  const posts = db.collection('forum/posts');

  await assertSucceeds(
    posts.add({
      authorId: 'poster',
      authorName: 'Pat',
      text: 'Hello world',
      timestamp: Date.now(),
    })
  );

  await assertFails(
    posts.add({
      authorId: 'someone-else',
      authorName: 'Eve',
      text: 'Hi',
      timestamp: Date.now(),
    })
  );

  await assertFails(
    posts.add({
      authorId: 'poster',
      authorName: 'Pat',
      text: ''.padEnd(5000, 'x'),
      timestamp: Date.now(),
    })
  );
});

test('only the author can update or delete forum posts', async () => {
  const authorDb = userDb('author');
  const otherDb = userDb('reader');
  const postRef = authorDb.collection('forum/posts').doc('p1');

  await assertSucceeds(
    postRef.set({
      authorId: 'author',
      authorName: 'Ally',
      text: 'Original text',
      timestamp: Date.now(),
    })
  );

  await assertSucceeds(postRef.update({ text: 'Updated text' }));
  await assertFails(
    otherDb.collection('forum/posts').doc('p1').update({ text: 'Hacked' })
  );
  await assertFails(otherDb.collection('forum/posts').doc('p1').delete());
});

test('reports can be created but never read back by clients', async () => {
  const reporterDb = userDb('reporter');
  const reports = reporterDb.collection('reports');
  const reportRef = reports.doc('r1');

  await assertSucceeds(reportRef.set({ reason: 'spam', createdAt: Date.now() }));
  await assertFails(reportRef.get());
  await assertFails(reportRef.update({ resolved: true }));
});
