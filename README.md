# Maison du Calme — chaîne Roku personnelle

Un menu à moi sur la TV : respiration guidée, questions de réflexion, lanceur d'applications et sessions vidéo/audio.

## Sections

| Section | Contenu |
|---|---|
| **Accueil** | Salutation, date et heure, une question qui change toutes les 90 s, la respiration conseillée selon l'heure, 6 applications |
| **Respiration** | 17 techniques guidées avec cercle animé, compte à rebours, rounds et rétentions chronométrées |
| **Réflexion** | 433 questions sur 12 thèmes, dans un ordre mélangé ; aucune ne revient avant que toutes aient été vues |
| **Applications** | Toutes les chaînes installées sur la Roku, avec leurs icônes ; OK pour lancer |
| **Sessions** | Vos propres flux vidéo/audio (`data/sessions.json`) |

Télécommande : ← / → pour passer du menu au contenu, OK pour choisir, Retour pour revenir.

## Techniques de respiration

Cohérence cardiaque · Soupir physiologique · Respiration carrée · 4-7-8 · Expiration prolongée 4-8 ·
Respiration abdominale · Triangle · Wim Hof · Tummo · Bhastrika · Kapalabhati · Nadi Shodhana ·
Bhramari · Ujjayi · Respiration du lion · Pause de contrôle Buteyko · Résonance.

Les techniques d'hyperventilation (Wim Hof, Tummo, Bhastrika, Kapalabhati) affichent un avertissement
avant de commencer. Pendant les rétentions libres (Wim Hof, Buteyko), appuyez sur OK quand vous
reprenez votre souffle : vos temps s'affichent à la fin.

Ajouter ou modifier une technique : `channel/data/breathwork.json`. Chaque étape a une phase
(`in`, `sniff`, `out`, `hold`, `holdEmpty`), une durée `s` en secondes, un texte `t` optionnel,
et `"open": true` pour une rétention libre.

## Lancer les autres applications

Le lanceur utilise le protocole de contrôle réseau de la Roku. Si la section Applications reste vide :
**Paramètres › Système › Paramètres système avancés › Contrôle par applications mobiles › Accès réseau : Autorisé**.

Limite de Roku : le bouton Home ramène toujours au menu Roku, et quitter une app ramène au menu Roku.
Placez Maison du Calme en premier sur l'écran d'accueil Roku pour l'avoir sous la main.

## Installer

1. Mode développeur sur la télécommande : Home ×3, Haut ×2, Droite, Gauche, Droite, Gauche, Droite.
2. `ROKU_IP=192.168.1.50 ROKU_PASS=motdepasse ./scripts/deploy.sh`
   (ou zipper le *contenu* de `channel/` et l'envoyer sur `http://<ip-roku>`).
3. Journaux : `telnet <ip-roku> 8085`

## Structure

```
channel/
  manifest
  source/main.brs
  components/
    MainScene.*        menu latéral, navigation, avertissements, lecture
    HomeScreen.*       accueil
    BreathScreen.*     liste des techniques
    BreathPlayer.*     moteur de respiration guidée
    ReflectScreen.*    questions
    AppsScreen.*       lanceur d'applications
    AppsTask.*         liste/lance les apps (thread séparé)
    SessionsScreen.*   flux vidéo/audio
    Tile.*             carte réutilisée partout
    QuestionDeck.brs   ordre mélangé sans répétition
    Common.brs
  data/
    breathwork.json  questions.json  sessions.json
  images/
scripts/deploy.sh
```
