import '../models/influencer.dart';
import '../core/enums.dart';

/// Predefined influencer archetypes that can appear in FinTok
/// Each template has 'en' and 'fr' localized strings for bio, phrases, catchphrases
const List<Map<String, dynamic>> influencerTemplates = [
  // === BULLISH INFLUENCERS ===
  {
    'id': 'rocket_randy',
    'name': 'Rocket Randy',
    'handle': '@ToTheMoon420',
    'avatar': '🚀',
    'type': InfluencerType.bullish,
    'baseAccuracy': 0.45,
    'bio': {
      'en': 'Diamond hands only! Every dip is a buying opportunity!',
      'fr': 'Mains de diamant uniquement ! Chaque baisse est une opportunite d\'achat !',
    },
    'bullishPhrases': {
      'en': [
        'is EXPLODING! Buy before it\'s too late! 🚀🚀🚀',
        'to the MOON! This is financial advice (NFA)!',
        'is gonna 10x EASY! Trust me bro!',
        'dip? More like a DISCOUNT! Loading up!',
      ],
      'fr': [
        'EXPLOSE ! Achetez avant qu\'il soit trop tard ! 🚀🚀🚀',
        'direction la LUNE ! Ceci est un conseil financier (NFA) !',
        'va faire x10 FACILE ! Faites-moi confiance !',
        'en baisse ? C\'est une PROMO ! J\'en reprends !',
      ],
    },
    'bearishPhrases': {
      'en': [
        'is on sale! Time to BUY THE DIP!',
        'weak hands selling, diamond hands buying!',
      ],
      'fr': [
        'est en solde ! C\'est le moment d\'ACHETER LE DIP !',
        'les mains de papier vendent, les mains de diamant achetent !',
      ],
    },
    'catchphrases': {
      'en': ['LFG!', 'WAGMI!', 'NFA but yes FA!', 'Apes together strong!'],
      'fr': ['LFG !', 'WAGMI !', 'NFA mais oui FA !', 'Singes ensemble forts !'],
    },
  },
  {
    'id': 'crypto_chad',
    'name': 'Crypto Chad',
    'handle': '@ChadBuysTheDip',
    'avatar': '💎',
    'type': InfluencerType.bullish,
    'specialtySector': SectorType.crypto,
    'baseAccuracy': 0.35,
    'bio': {
      'en': 'Turned \$100 into \$50. Still bullish.',
      'fr': 'A transforme 100\$ en 50\$. Toujours bullish.',
    },
    'bullishPhrases': {
      'en': [
        'is the next Bitcoin! Don\'t miss out!',
        'fundamentals are INSANE! Easy 100x!',
        'whales are accumulating secretly!',
      ],
      'fr': [
        'c\'est le prochain Bitcoin ! Ne ratez pas ca !',
        'les fondamentaux sont DINGUES ! 100x facile !',
        'les baleines accumulent en secret !',
      ],
    },
    'bearishPhrases': {
      'en': ['FUD is temporary, gains are forever!'],
      'fr': ['Le FUD est temporaire, les gains sont eternels !'],
    },
    'catchphrases': {
      'en': ['HODL!', 'Few understand.', 'Have fun staying poor!'],
      'fr': ['HODL !', 'Peu comprennent.', 'Amusez-vous a rester pauvre !'],
    },
  },

  // === BEARISH INFLUENCERS ===
  {
    'id': 'doom_dan',
    'name': 'Doom Dan',
    'handle': '@CrashIncoming',
    'avatar': '📉',
    'type': InfluencerType.bearish,
    'baseAccuracy': 0.40,
    'bio': {
      'en': 'Predicting crashes since 2008. Was right once.',
      'fr': 'Predit des crashs depuis 2008. A eu raison une fois.',
    },
    'bullishPhrases': {
      'en': ['pump is fake. Sell before it crashes!'],
      'fr': ['la hausse est fausse. Vendez avant le crash !'],
    },
    'bearishPhrases': {
      'en': [
        'is about to CRASH! I warned you!',
        'bubble is popping! Get out NOW!',
        'dead cat bounce. Don\'t fall for it!',
        'insiders are selling. You should too!',
      ],
      'fr': [
        'va CRASHER ! Je vous avais prevenu !',
        'la bulle eclate ! Sortez MAINTENANT !',
        'rebond du chat mort. Ne tombez pas dans le piege !',
        'les inities vendent. Vous devriez aussi !',
      ],
    },
    'catchphrases': {
      'en': ['The end is nigh!', 'Told you so!', 'Cash is king!'],
      'fr': ['La fin est proche !', 'Je vous l\'avais dit !', 'Le cash est roi !'],
    },
  },
  {
    'id': 'short_sally',
    'name': 'Short Sally',
    'handle': '@BearishAndProud',
    'avatar': '🐻',
    'type': InfluencerType.bearish,
    'baseAccuracy': 0.42,
    'bio': {
      'en': 'Professional pessimist. Short everything.',
      'fr': 'Pessimiste professionnelle. Shorter tout.',
    },
    'bullishPhrases': {
      'en': ['rally is fake. Short it!'],
      'fr': ['le rallye est faux. Shortez !'],
    },
    'bearishPhrases': {
      'en': [
        'is overvalued by 500%! SHORT IT!',
        'fundamentals are garbage! Easy short!',
        'management is lying! Short opportunity!',
      ],
      'fr': [
        'est surevalue de 500% ! SHORTEZ !',
        'les fondamentaux sont nuls ! Short facile !',
        'la direction ment ! Opportunite de short !',
      ],
    },
    'catchphrases': {
      'en': ['Bears make money!', 'Gravity always wins!'],
      'fr': ['Les bears font de l\'argent !', 'La gravite gagne toujours !'],
    },
  },

  // === SECTOR EXPERTS ===
  {
    'id': 'tech_tim',
    'name': 'Tech Tim',
    'handle': '@TechGainz',
    'avatar': '💻',
    'type': InfluencerType.sectorExpert,
    'specialtySector': SectorType.technology,
    'baseAccuracy': 0.55,
    'bio': {
      'en': 'Ex-FAANG engineer. I know things.',
      'fr': 'Ex-ingenieur FAANG. Je sais des choses.',
    },
    'bullishPhrases': {
      'en': [
        'AI integration will 5x revenue!',
        'tech stack is revolutionary!',
        'cloud metrics are off the charts!',
      ],
      'fr': [
        'l\'IA va multiplier le CA par 5 !',
        'la stack techno est revolutionnaire !',
        'les metriques cloud sont hors normes !',
      ],
    },
    'bearishPhrases': {
      'en': [
        'tech debt is unsustainable!',
        'competition is eating their lunch!',
      ],
      'fr': [
        'la dette technique est insoutenable !',
        'la concurrence les devore !',
      ],
    },
    'catchphrases': {
      'en': ['Disruption incoming!', 'The future is now!'],
      'fr': ['Disruption en vue !', 'Le futur c\'est maintenant !'],
    },
  },
  {
    'id': 'pharma_phil',
    'name': 'Pharma Phil',
    'handle': '@PillPusher',
    'avatar': '💊',
    'type': InfluencerType.sectorExpert,
    'specialtySector': SectorType.healthcare,
    'baseAccuracy': 0.52,
    'bio': {
      'en': 'Former pharma sales. I read FDA filings.',
      'fr': 'Ex-commercial pharma. Je lis les dossiers FDA.',
    },
    'bullishPhrases': {
      'en': [
        'FDA approval is a lock!',
        'trial results leaked - it\'s good!',
        'pipeline is undervalued!',
      ],
      'fr': [
        'l\'approbation FDA est acquise !',
        'les resultats de l\'essai ont fuite - c\'est bon !',
        'le pipeline est sous-evalue !',
      ],
    },
    'bearishPhrases': {
      'en': [
        'trial will fail! Sell!',
        'FDA rejection incoming!',
      ],
      'fr': [
        'l\'essai va echouer ! Vendez !',
        'refus FDA imminent !',
      ],
    },
    'catchphrases': {
      'en': ['Trust the science!', 'Phase 3 szn!'],
      'fr': ['Faites confiance a la science !', 'Saison Phase 3 !'],
    },
  },
  {
    'id': 'energy_emma',
    'name': 'Energy Emma',
    'handle': '@OilBaroness',
    'avatar': '⛽',
    'type': InfluencerType.sectorExpert,
    'specialtySector': SectorType.energy,
    'baseAccuracy': 0.50,
    'bio': {
      'en': 'Energy sector analyst. Yes, oil still matters.',
      'fr': 'Analyste du secteur energetique. Oui, le petrole compte encore.',
    },
    'bullishPhrases': {
      'en': [
        'oil prices are going UP!',
        'energy crisis = energy profits!',
        'dividends are JUICY!',
      ],
      'fr': [
        'le prix du petrole va MONTER !',
        'crise energetique = profits energetiques !',
        'les dividendes sont JUTEUX !',
      ],
    },
    'bearishPhrases': {
      'en': [
        'renewables are killing them!',
        'oversupply incoming!',
      ],
      'fr': [
        'les renouvelables les tuent !',
        'surproduction en approche !',
      ],
    },
    'catchphrases': {
      'en': ['Black gold baby!', 'Energy independence!'],
      'fr': ['Or noir baby !', 'Independance energetique !'],
    },
  },

  // === MEME TRADERS ===
  {
    'id': 'yolo_yolanda',
    'name': 'YOLO Yolanda',
    'handle': '@YOLOorBust',
    'avatar': '🎰',
    'type': InfluencerType.memeTrader,
    'baseAccuracy': 0.30,
    'bio': {
      'en': 'All in or nothing. Currently at nothing.',
      'fr': 'Tout ou rien. Actuellement a rien.',
    },
    'bullishPhrases': {
      'en': [
        'vibes are IMMACULATE! All in!',
        'chart looks like a rocket! 🚀',
        'trust the process! YOLO!',
      ],
      'fr': [
        'les vibes sont PARFAITES ! All in !',
        'le graphique ressemble a une fusee ! 🚀',
        'faites confiance au processus ! YOLO !',
      ],
    },
    'bearishPhrases': {
      'en': ['giving me bad vibes! Selling everything!'],
      'fr': ['me donne de mauvaises vibes ! Je vends tout !'],
    },
    'catchphrases': {
      'en': ['YOLO!', 'Fortune favors the bold!', 'No risk no reward!'],
      'fr': ['YOLO !', 'La fortune sourit aux audacieux !', 'Pas de risque pas de gain !'],
    },
  },
  {
    'id': 'meme_mike',
    'name': 'Meme Mike',
    'handle': '@WallStBets',
    'avatar': '🦍',
    'type': InfluencerType.memeTrader,
    'baseAccuracy': 0.28,
    'bio': {
      'en': 'Ape see dip, ape buy dip.',
      'fr': 'Singe voit dip, singe achete dip.',
    },
    'bullishPhrases': {
      'en': [
        'is the next GME! Apes assemble!',
        'short squeeze incoming!',
        'hedgies hate this stock! BUY!',
      ],
      'fr': [
        'c\'est le prochain GME ! Singes rassemblement !',
        'short squeeze en approche !',
        'les hedge funds detestent cette action ! ACHETEZ !',
      ],
    },
    'bearishPhrases': {
      'en': ['paper hands selling! Pathetic!'],
      'fr': ['les mains de papier vendent ! Pathetique !'],
    },
    'catchphrases': {
      'en': ['Apes strong!', 'To Valhalla!', 'We like the stock!'],
      'fr': ['Singes forts !', 'Direction le Valhalla !', 'On aime l\'action !'],
    },
  },

  // === TECHNICAL GURUS ===
  {
    'id': 'chart_charlie',
    'name': 'Chart Charlie',
    'handle': '@ChartWhisperer',
    'avatar': '📊',
    'type': InfluencerType.technicalGuru,
    'baseAccuracy': 0.48,
    'bio': {
      'en': 'I see patterns others don\'t. Mostly imaginary.',
      'fr': 'Je vois des patterns que les autres ne voient pas. Souvent imaginaires.',
    },
    'bullishPhrases': {
      'en': [
        'forming a classic cup and handle!',
        'golden cross confirmed! BUY!',
        'support held perfectly! Moon time!',
      ],
      'fr': [
        'forme une tasse avec anse classique !',
        'golden cross confirme ! ACHETEZ !',
        'le support a tenu parfaitement ! Direction la lune !',
      ],
    },
    'bearishPhrases': {
      'en': [
        'death cross forming! SELL!',
        'head and shoulders = crash!',
        'broke support! Abandon ship!',
      ],
      'fr': [
        'death cross en formation ! VENDEZ !',
        'tete et epaules = crash !',
        'support casse ! Abandonnez le navire !',
      ],
    },
    'catchphrases': {
      'en': ['The charts don\'t lie!', 'Technical analysis is science!'],
      'fr': ['Les graphiques ne mentent pas !', 'L\'analyse technique est une science !'],
    },
  },
  {
    'id': 'fib_fiona',
    'name': 'Fib Fiona',
    'handle': '@FibonacciQueen',
    'avatar': '🔮',
    'type': InfluencerType.technicalGuru,
    'baseAccuracy': 0.45,
    'bio': {
      'en': 'Fibonacci retracement is my religion.',
      'fr': 'Le retracement de Fibonacci est ma religion.',
    },
    'bullishPhrases': {
      'en': [
        'hit the 61.8% retracement! BUY SIGNAL!',
        'bounced off the golden ratio!',
      ],
      'fr': [
        'a touche le retracement 61.8% ! SIGNAL D\'ACHAT !',
        'a rebondi sur le nombre d\'or !',
      ],
    },
    'bearishPhrases': {
      'en': [
        'broke the 38.2% level! DANGER!',
        'rejecting at resistance! Short it!',
      ],
      'fr': [
        'a casse le niveau 38.2% ! DANGER !',
        'rejete a la resistance ! Shortez !',
      ],
    },
    'catchphrases': {
      'en': ['Fibonacci knows all!', 'Math > emotions!'],
      'fr': ['Fibonacci sait tout !', 'Maths > emotions !'],
    },
  },

  // === INSIDER TIPPERS ===
  {
    'id': 'inside_ian',
    'name': 'Insider Ian',
    'handle': '@TrustMeBro',
    'avatar': '🤫',
    'type': InfluencerType.insiderTipper,
    'baseAccuracy': 0.38,
    'bio': {
      'en': 'I know a guy who knows a guy.',
      'fr': 'Je connais un gars qui connait un gars.',
    },
    'bullishPhrases': {
      'en': [
        '- my source says HUGE announcement coming!',
        '- insiders loading up! Something big!',
        '- trust me, buy before Friday!',
      ],
      'fr': [
        '- ma source dit qu\'une ENORME annonce arrive !',
        '- les inities chargent ! Quelque chose de gros !',
        '- faites-moi confiance, achetez avant vendredi !',
      ],
    },
    'bearishPhrases': {
      'en': [
        '- heard bad news is coming! Get out!',
        '- execs are selling secretly!',
      ],
      'fr': [
        '- j\'ai entendu que de mauvaises nouvelles arrivent ! Sortez !',
        '- les dirigeants vendent en secret !',
      ],
    },
    'catchphrases': {
      'en': ['You didn\'t hear this from me!', 'My sources are solid!'],
      'fr': ['Vous ne l\'avez pas entendu de moi !', 'Mes sources sont solides !'],
    },
  },
  {
    'id': 'whisper_wendy',
    'name': 'Whisper Wendy',
    'handle': '@WallStWhispers',
    'avatar': '👂',
    'type': InfluencerType.insiderTipper,
    'baseAccuracy': 0.42,
    'bio': {
      'en': 'Connected to the right people. Allegedly.',
      'fr': 'Connectee aux bonnes personnes. Soi-disant.',
    },
    'bullishPhrases': {
      'en': [
        '- whispers of a major partnership!',
        '- hearing acquisition rumors!',
        '- smart money is accumulating!',
      ],
      'fr': [
        '- on murmure un partenariat majeur !',
        '- des rumeurs d\'acquisition circulent !',
        '- l\'argent intelligent accumule !',
      ],
    },
    'bearishPhrases': {
      'en': [
        '- hearing layoffs coming!',
        '- CFO rumored to be leaving!',
      ],
      'fr': [
        '- j\'entends des licenciements arrivent !',
        '- le CFO envisagerait de partir !',
      ],
    },
    'catchphrases': {
      'en': ['Whisper networks don\'t lie!', 'Follow the smart money!'],
      'fr': ['Les reseaux de murmures ne mentent pas !', 'Suivez l\'argent intelligent !'],
    },
  },
];

/// Farewell messages based on departure reason (bilingual)
const Map<String, List<String>> shamefulFarewells = {
  'en': [
    'Taking a break from FinTok to focus on my mental health. (Accuracy: {accuracy}%)',
    'The market is rigged! That\'s why my calls didn\'t work! Goodbye!',
    'Going back to my day job. Trading isn\'t for everyone.',
    'My strategies work better in backtesting. See you never!',
    'Deleting my account. You guys didn\'t deserve my alpha anyway!',
  ],
  'fr': [
    'Je fais une pause de FinTok pour ma sante mentale. (Precision : {accuracy}%)',
    'Le marche est truque ! C\'est pour ca que mes calls n\'ont pas marche ! Adieu !',
    'Je retourne a mon travail. Le trading n\'est pas pour tout le monde.',
    'Mes strategies marchent mieux en backtesting. A jamais !',
    'Je supprime mon compte. Vous ne meritiez pas mon alpha de toute facon !',
  ],
};

const Map<String, List<String>> normalFarewells = {
  'en': [
    'It\'s been real! Moving on to new opportunities. Final accuracy: {accuracy}%',
    'Thanks for following! Time to go private. Good luck everyone!',
    'Taking my talents elsewhere. Stay profitable!',
    'New chapter awaits! Keep making those gains!',
    'Signing off! Remember: past performance doesn\'t guarantee future results!',
  ],
  'fr': [
    'C\'etait sympa ! Je passe a autre chose. Precision finale : {accuracy}%',
    'Merci de m\'avoir suivi ! Je passe en prive. Bonne chance a tous !',
    'J\'emmene mes talents ailleurs. Restez profitables !',
    'Un nouveau chapitre m\'attend ! Continuez a gagner !',
    'Je me deconnecte ! N\'oubliez pas : les perfs passees ne garantissent pas les resultats futurs !',
  ],
};

const Map<String, List<String>> victoryFarewells = {
  'en': [
    'Made enough to retire! Thanks for believing in me! {accuracy}% accuracy!',
    'Going private to manage my own fund. You\'re all gonna make it!',
    'Mission accomplished! {accuracy}% accuracy speaks for itself!',
    'Time to enjoy the gains! Best of luck to all my followers!',
  ],
  'fr': [
    'Assez gagne pour prendre ma retraite ! Merci d\'avoir cru en moi ! {accuracy}% de precision !',
    'Je passe en prive pour gerer mon propre fonds. Vous allez tous y arriver !',
    'Mission accomplie ! {accuracy}% de precision, ca parle tout seul !',
    'C\'est l\'heure de profiter des gains ! Bonne chance a tous mes abonnes !',
  ],
};

/// Helper to extract localized string from a bilingual map
String _localized(dynamic value, String locale) {
  if (value is Map) {
    return (value[locale] ?? value['en'] ?? '') as String;
  }
  return value?.toString() ?? '';
}

/// Helper to extract localized string list from a bilingual map
List<String> _localizedList(dynamic value, String locale) {
  if (value is Map) {
    final list = value[locale] ?? value['en'];
    if (list is List) return List<String>.from(list);
  }
  if (value is List) return List<String>.from(value);
  return [];
}

/// Create an Influencer instance from a template with locale support
Influencer createInfluencerFromTemplate(Map<String, dynamic> template, int arrivalDay, {String locale = 'en'}) {
  return Influencer(
    id: template['id'],
    name: template['name'],
    handle: template['handle'],
    avatar: template['avatar'],
    bio: _localized(template['bio'], locale),
    type: template['type'],
    specialtySector: template['specialtySector'],
    baseAccuracy: template['baseAccuracy'],
    dayArrived: arrivalDay,
    followers: (500 + (template['baseAccuracy'] * 2000)).toInt(),
    bullishPhrases: _localizedList(template['bullishPhrases'], locale),
    bearishPhrases: _localizedList(template['bearishPhrases'], locale),
    catchphrases: _localizedList(template['catchphrases'], locale),
  );
}

/// Get localized phrases for an influencer template (used at tip generation time)
List<String> getInfluencerPhrases(String influencerId, bool bullish, String locale) {
  for (final template in influencerTemplates) {
    if (template['id'] == influencerId) {
      final key = bullish ? 'bullishPhrases' : 'bearishPhrases';
      return _localizedList(template[key], locale);
    }
  }
  return [];
}

/// Get localized catchphrases for an influencer template
List<String> getInfluencerCatchphrases(String influencerId, String locale) {
  for (final template in influencerTemplates) {
    if (template['id'] == influencerId) {
      return _localizedList(template['catchphrases'], locale);
    }
  }
  return [];
}

/// Get localized bio for an influencer template (for UI display)
String getInfluencerBio(String influencerId, String locale) {
  for (final template in influencerTemplates) {
    if (template['id'] == influencerId) {
      return _localized(template['bio'], locale);
    }
  }
  return '';
}

/// Get a farewell message based on accuracy (localized)
String getFarewellMessage(double accuracy, {String locale = 'en'}) {
  Map<String, List<String>> messagesMap;
  if (accuracy < 0.3) {
    messagesMap = shamefulFarewells;
  } else if (accuracy >= 0.6) {
    messagesMap = victoryFarewells;
  } else {
    messagesMap = normalFarewells;
  }

  final messages = messagesMap[locale] ?? messagesMap['en']!;
  final index = (accuracy * 100).round() % messages.length;
  final message = messages[index];
  return message.replaceAll('{accuracy}', (accuracy * 100).toStringAsFixed(0));
}
