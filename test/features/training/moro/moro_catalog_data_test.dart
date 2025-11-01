import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Moro catalog data', () {
    late List<Map<String, dynamic>> exercises;

    setUpAll(() {
      final file = File('assets/moro/moro_exercises.json');
      exercises = (jsonDecode(file.readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();
    });

    test('has consistent timing configuration', () {
      expect(exercises, hasLength(7));

      for (final entry in exercises.where((e) => e['index'] <= 5)) {
        expect(entry['repeats'], 3, reason: 'Exercises 1-5 use 3 Wiederholungen');
        expect(entry['phasesPerRepeat'], 4,
            reason: 'Exercises 1-5 should have four Phasen');
        expect(entry['baseSeconds'], 3,
            reason: 'Exercises 1-5 baseline seconds must be 3');
        expect(entry['xpReward'], 30,
            reason: 'Exercises 1-5 grant 30 XP each');
        final breath = entry['breath'] as Map<String, dynamic>;
        expect(breath['exhaleSec'], 7,
            reason: 'Exercises 1-5 keep the seven second Ausatmung');
      }

      for (final entry in exercises.where((e) => e['index'] >= 6)) {
        expect(entry['repeats'], 6, reason: 'Exercises 6-7 use 6 Wiederholungen');
        expect(entry['phasesPerRepeat'], 1,
            reason: 'Exercises 6-7 are simple with one Phase');
        expect(entry['baseSeconds'], 7,
            reason: 'Exercises 6-7 baseline seconds must be 7');
        expect(entry['xpReward'], 60,
            reason: 'Exercises 6-7 grant 60 XP each');
        final breath = entry['breath'] as Map<String, dynamic>;
        expect(breath['exhaleSec'], 7,
            reason: 'Exercises 6-7 keep the seven second Ausatmung');
      }
    });

    test('provides detailed guidance per exercise', () {
      final expected = <int, Map<String, dynamic>>{
        1: {
          'startPosition':
              'Rückenlage mit ausgestreckten Beinen, Hände flach neben dem Körper, Augen offen.',
          'steps': const [
            {
              'order': 1,
              'text':
                  'Atme drei Sekunden ruhig ein, lege Hände offen ab und stabilisiere den Kopf neutral.',
              'durationSec': 3,
            },
            {
              'order': 2,
              'text':
                  'Lass beide Knie in drei Sekunden nach rechts sinken, während Schultern am Boden bleiben.',
              'durationSec': 3,
            },
            {
              'order': 3,
              'text':
                  'Führe die Knie in drei Sekunden zurück zur Mitte und bereite den Wechsel vor.',
              'durationSec': 3,
            },
            {
              'order': 4,
              'text':
                  'Wiederhole die Bewegung in drei Sekunden nach links und kehre danach zur Mitte zurück.',
              'durationSec': 3,
            },
          ],
          'cues': const [
            'Lass die Bewegung weich aus dem Becken starten.',
            'Kniescheiben zeigen nach oben, Füße entspannt.',
            'Augen bleiben offen für Orientierung.',
          ],
          'notes':
              'Arbeite mit kleinem Bewegungsradius, wenn die Lendenwirbelsäule empfindlich reagiert.',
        },
        2: {
          'startPosition':
              'Rückenlage, Beine hüftbreit angewinkelt, Hände fassen nicht, sondern liegen flach neben dem Körper.',
          'steps': const [
            {
              'order': 1,
              'text':
                  'Bereite dich in drei Sekunden mit ruhiger Einatmung vor und entspanne Schultern sowie Gesicht.',
              'durationSec': 3,
            },
            {
              'order': 2,
              'text':
                  'Atme lang aus und rolle Oberkörper sowie Kopf innerhalb von drei Sekunden Richtung Knie.',
              'durationSec': 3,
            },
            {
              'order': 3,
              'text':
                  'Halte die Position für drei Sekunden mit sanfter Bauchspannung.',
              'durationSec': 3,
            },
            {
              'order': 4,
              'text':
                  'Lege dich in drei Sekunden wieder Wirbel für Wirbel zurück auf die Matte.',
              'durationSec': 3,
            },
          ],
          'cues': const [
            'Core weich aktiv – keine harte Pressatmung.',
            'Nacken lang lassen, Blick zu den Knien.',
            'Regression: Schienbeine mit den Händen umfassen, falls nötig.',
          ],
          'notes':
              'Arbeite nur so hoch wie sich der Nacken wohlfühlt; Fokus auf gleichmäßige Bewegung.',
        },
        3: {
          'startPosition':
              'Rückenlage, ein Bein ausgestreckt, anderes Bein beginnt gleitend an der Innenseite entlang.',
          'steps': const [
            {
              'order': 1,
              'text':
                  'Finde in drei Sekunden mit ruhigem Atem die neutrale Rückenlage und lege die Hände weich ab.',
              'durationSec': 3,
            },
            {
              'order': 2,
              'text':
                  'Führe die Fußsohle in drei Sekunden entlang des gestreckten Beins nach oben – der Kontakt bleibt erhalten.',
              'durationSec': 3,
            },
            {
              'order': 3,
              'text': 'Halte die Öffnung für drei Sekunden, ohne das Becken zu drehen.',
              'durationSec': 3,
            },
            {
              'order': 4,
              'text':
                  'Gleite in drei Sekunden kontrolliert zurück nach unten und bereite den Seitenwechsel vor.',
              'durationSec': 3,
            },
          ],
          'cues': const [
            'Nur so weit öffnen, wie der Fuß Kontakt hält.',
            'Becken bleibt ruhig, Lendenwirbelsäule neutral.',
            'Schultern und Hände bleiben weich auf der Unterlage.',
          ],
          'notes': 'Platziere ggf. ein Tuch unter der gleitenden Ferse für weniger Reibung.',
        },
        4: {
          'startPosition':
              'Rückenlage, Fußsohlen berühren sich, Knie fallen entspannt nach außen.',
          'steps': const [
            {
              'order': 1,
              'text':
                  'Atme drei Sekunden weich ein, lege Hände offen neben dem Körper und richte den Blick nach oben.',
              'durationSec': 3,
            },
            {
              'order': 2,
              'text':
                  'Ziehe die Fersen in drei Sekunden Richtung Körper, ohne den Fußkontakt zu verlieren.',
              'durationSec': 3,
            },
            {
              'order': 3,
              'text':
                  'Halte die Fußsohlen für drei Sekunden verbunden und atme in die Leisten.',
              'durationSec': 3,
            },
            {
              'order': 4,
              'text':
                  'Lass die Beine in drei Sekunden kontrolliert wieder nach außen gleiten.',
              'durationSec': 3,
            },
          ],
          'cues': const [
            'Nur so weit ziehen, wie die Fußsohlen flächig bleiben.',
            'Atme weich in den Bauch, lass die Leisten los.',
            'Knie hängen schwer, nicht aktiv nach unten drücken.',
          ],
          'notes': 'Unterstütze die Knie bei Bedarf mit Blöcken oder Kissen.',
        },
        5: {
          'startPosition':
              'Rückenlage, ein Bein bleibt lang, das andere hebt zur Auflage auf dem Schienbein.',
          'steps': const [
            {
              'order': 1,
              'text':
                  'Stabilisiere Arme und Hände in drei Sekunden in der Preroll-Position, Blick zur Decke.',
              'durationSec': 3,
            },
            {
              'order': 2,
              'text':
                  'Hebe ein Bein in drei Sekunden an und führe es kontrolliert über das andere Bein.',
              'durationSec': 3,
            },
            {
              'order': 3,
              'text': 'Halte die Auflage für drei Sekunden mit gleichmäßigem Atem.',
              'durationSec': 3,
            },
            {
              'order': 4,
              'text': 'Führe das Bein in drei Sekunden zurück und wechsle die Seite.',
              'durationSec': 3,
            },
          ],
          'cues': const [
            'Das ruhende Bein bleibt am Boden verankert.',
            'Hände drücken sanft in die Unterlage für Stabilität.',
            'Augen bleiben offen und folgen der Bewegung nicht.',
          ],
          'notes': 'Nutze einen Gurt, falls das Ablegen des Unterschenkels schwer fällt.',
        },
        6: {
          'startPosition':
              'Rückenlage, Hände an die Knie gelegt, Beine leicht vom Körper weg, Arme gestreckt.',
          'steps': const [
            {
              'order': 1,
              'text':
                  'Bereite dich mit tiefer Einatmung vor, Hände liegen flach auf den Knien.',
            },
            {
              'order': 2,
              'text':
                  'Strecke Beine sanft nach vorne und bau über sieben Sekunden Gegendruck mit den Handflächen auf.',
              'durationSec': 7,
            },
            {
              'order': 3,
              'text': 'Halte die Spannung kurz, atme nach, löse für drei Sekunden.',
              'durationSec': 3,
            },
            {
              'order': 4,
              'text': 'Wiederhole insgesamt sechs Runden mit ruhiger Atmung.',
            },
          ],
          'cues': const [
            'Spannung gleichmäßig auf beide Seiten verteilen.',
            'Nacken bleibt lang, Hinterkopf am Boden.',
            'Ausatmung fließt durch den Mund, ohne Pressen.',
          ],
          'notes':
              'Passe den Druck an – Ziel ist ein gleichmäßiger Widerstand, kein Zittern.',
        },
        7: {
          'startPosition':
              'Rückenlage, Arme überkreuzen auf den Oberschenkeln, Kopf leicht zur Brust geneigt.',
          'steps': const [
            {
              'order': 1,
              'text':
                  'Leg die Arme überkreuz auf Oberschenkel und finde eine lange Halswirbelsäule.',
            },
            {
              'order': 2,
              'text':
                  'Zieh die Beine mit der Ausatmung für sieben Sekunden zum Körper, Hände halten gleichmäßig dagegen.',
              'durationSec': 7,
            },
            {
              'order': 3,
              'text': 'Halte drei Sekunden Pause, lass Schultern sinken und atme nach.',
              'durationSec': 3,
            },
            {
              'order': 4,
              'text': 'Nach drei Wiederholungen Arme neu kreuzen und Richtung wechseln.',
            },
          ],
          'cues': const [
            'Kopf bleibt leicht zur Brust geneigt, Blick weich nach vorne.',
            'Zieh gleichmäßig aus beiden Beinen, ohne zu ruckeln.',
            'Spür die diagonale Verbindung zwischen Händen und Rumpf.',
          ],
          'notes': 'Unterstütze den Kopf bei Bedarf mit einem kleinen Kissen.',
        },
      };

      for (final entry in exercises) {
        final idx = entry['index'] as int;
        final expectedEntry = expected[idx]!;

        expect(entry['startPosition'], expectedEntry['startPosition']);

        final steps =
            List<Map<String, dynamic>>.from(entry['steps'] as List<dynamic>);
        final expectedSteps =
            (expectedEntry['steps'] as List).cast<Map<String, dynamic>>();
        expect(steps.length, expectedSteps.length,
            reason: 'Exercise $idx should define ${expectedSteps.length} Schritte');
        for (var i = 0; i < steps.length; i++) {
          final actualStep = steps[i];
          final expectedStep = expectedSteps[i];
          expect(actualStep['order'], expectedStep['order']);
          expect(actualStep['text'], expectedStep['text']);
          if (expectedStep.containsKey('durationSec')) {
            expect(actualStep['durationSec'], expectedStep['durationSec']);
          } else {
            expect(actualStep.containsKey('durationSec'), isFalse);
          }
        }

        final cues = List<String>.from(entry['cues'] as List);
        final expectedCues =
            (expectedEntry['cues'] as List).cast<String>();
        expect(cues, expectedCues);

        expect(entry['notes'], expectedEntry['notes']);
      }
    });
  });
}
