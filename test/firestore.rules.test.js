const fs = require('fs');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'bugbear-test',
    firestore: {
      rules: fs.readFileSync('firestore.rules', 'utf8'),
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

function getDb(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function getAnonDb() {
  return testEnv.unauthenticatedContext().firestore();
}

test('user can read and write own user document', async () => {
  const db = getDb('alice');
  await assertSucceeds(db.collection('users').doc('alice').set({foo: 'bar'}));
  await assertSucceeds(db.collection('users').doc('alice').get());
});

test('user cannot read other user document', async () => {
  const db = getDb('bob');
  await assertFails(db.collection('users').doc('alice').get());
});

test('user can manage own profile', async () => {
  const db = getDb('alice');
  await assertSucceeds(
    db
      .collection('users')
      .doc('alice')
      .collection('profiles')
      .doc('p1')
      .set({foo: 'bar'})
  );
  await assertSucceeds(
    db.collection('users').doc('alice').collection('profiles').doc('p1').get()
  );
});

test('user cannot access unknown subcollection', async () => {
  const db = getDb('alice');
  await assertFails(
    db
      .collection('users')
      .doc('alice')
      .collection('unknown')
      .doc('x')
      .get()
  );
});

test('user cannot read from unknown top-level collection', async () => {
  const db = getDb('alice');
  await assertFails(db.collection('other').doc('doc').get());
});

test('unauthenticated access is denied', async () => {
  const db = getAnonDb();
  await assertFails(db.collection('users').doc('alice').get());
});
