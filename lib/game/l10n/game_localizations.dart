import 'package:flutter/widgets.dart';

/// A complete, translator-facing message. Keep placeholders named and stable.
class GameMessage {
  const GameMessage(
    this.turkish,
    this.english, [
    this.description = 'User-facing copy. Keep named placeholders unchanged.',
  ]);

  final String turkish;
  final String english;
  final String description;
}

class GameLocaleScope extends InheritedWidget {
  const GameLocaleScope({
    super.key,
    required this.languageCode,
    required super.child,
  });

  final String languageCode;

  static GameLocaleScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GameLocaleScope>();

  @override
  bool updateShouldNotify(GameLocaleScope oldWidget) =>
      languageCode != oldWidget.languageCode;
}

/// Stable message IDs used by the UI and game-content presentation layer.
/// Translator descriptions live beside the source and target messages.
const gameMessages = <String, GameMessage>{
  // Title and character creation.
  'ui.brand.name': GameMessage(
    'Kül Çemberi',
    'Kül Çemberi',
    'Game title; keep the established brand name unchanged.',
  ),
  'ui.title.tagline': GameMessage(
    'Fırtına adalarının dövüş ligi',
    'The fighting league of the Storm Isles',
    'Subtitle shown below the game title.',
  ),
  'ui.title.panel.heading': GameMessage(
    'Çember seni çağırıyor',
    'The Circle calls',
    'Heading on the title screen introduction panel.',
  ),
  'ui.title.panel.body': GameMessage(
    'Kendi dövüşçünü kur. Rakibin niyetini oku. Ligin arkasındaki gerçeği ortaya çıkar.',
    'Build your fighter. Read your rival’s intent. Uncover the truth behind the league.',
    'Introductory game description; three short imperative sentences.',
  ),
  'ui.title.createFighter': GameMessage(
    'Dövüşçünü oluştur',
    'Create your fighter',
    'Primary title-screen action.',
  ),
  'ui.title.footer': GameMessage(
    'Çevrimdışı tek oyunculu kampanya · 32 ana düello',
    'Offline single-player campaign · 32 main duels',
    'Compact feature summary on the title screen.',
  ),
  'ui.creator.title': GameMessage(
    'Dövüşçü yarat',
    'Create fighter',
    'App bar title for fighter creation.',
  ),
  'ui.creator.newFighter': GameMessage(
    'Yeni dövüşçü',
    'New fighter',
    'Temporary portrait label before the player names their fighter.',
  ),
  'ui.hero.defaultName': GameMessage(
    'Kıyı Dövüşçüsü',
    'Coast Fighter',
    'Fallback player name used when no name was provided.',
  ),
  'ui.creator.heading': GameMessage(
    'Kendi yolunu seç',
    'Choose your path',
    'Character creation intro heading.',
  ),
  'ui.creator.body': GameMessage(
    'Görünüşün savaş gücünü etkilemez. Altı özellik puanını istediğin yapıya dağıt.',
    'Your appearance does not affect combat power. Distribute six attribute points across the build you want.',
    'Character creation explanation.',
  ),
  'ui.creator.name': GameMessage(
    'Dövüşçü adı',
    'Fighter name',
    'Text field label for the player character name.',
  ),
  'ui.creator.appearance': GameMessage(
    'Başlangıç görünüşü',
    'Starting appearance',
    'Section heading above appearance choices.',
  ),
  'ui.appearance.edit': GameMessage(
    'Görünüşü düzenle',
    'Edit appearance',
    'Fighter page action that opens the appearance editor.',
  ),
  'ui.appearance.title': GameMessage(
    'Görünüş düzenleyici',
    'Appearance editor',
    'App bar title for post-creation appearance editing.',
  ),
  'ui.appearance.description': GameMessage(
    'Değişiklikler ücretsizdir, anında kaydedilir ve dövüş gücünü etkilemez.',
    'Changes are free, save instantly, and do not affect combat power.',
    'Explains post-creation appearance editing and its gameplay impact.',
  ),
  'ui.appearance.head': GameMessage(
    'Saç ve başlık',
    'Hair and headwear',
    'Appearance editor option group for head layers.',
  ),
  'ui.appearance.skin': GameMessage(
    'Ten tonu',
    'Skin tone',
    'Appearance editor option group for skin tones.',
  ),
  'ui.appearance.build': GameMessage(
    'Yapı',
    'Build',
    'Appearance editor option group for body proportions.',
  ),
  'ui.appearance.facialHair': GameMessage(
    'Yüz kılı',
    'Facial hair',
    'Appearance editor option group for facial hair styles.',
  ),
  'ui.appearance.option': GameMessage(
    '{group}, seçenek {count}',
    '{group}, option {count}',
    'Accessible label for an appearance option chip.',
  ),
  'ui.appearance.saveFailed': GameMessage(
    'Görünüş kaydedilemedi. Tekrar dene.',
    'Appearance could not be saved. Try again.',
    'Error shown when saving an appearance choice fails.',
  ),
  'ui.origin.coast': GameMessage(
    'Kıyı',
    'Coast',
    'Starting appearance choice; internal appearance ID remains unchanged.',
  ),
  'ui.origin.forge': GameMessage(
    'Ocak',
    'Forge',
    'Starting appearance choice; internal appearance ID remains unchanged.',
  ),
  'ui.origin.storm': GameMessage(
    'Fırtına',
    'Storm',
    'Starting appearance choice; internal appearance ID remains unchanged.',
  ),
  'ui.origin.crown': GameMessage(
    'Taç',
    'Crown',
    'Starting appearance choice; internal appearance ID remains unchanged.',
  ),
  'ui.creator.stats': GameMessage(
    'Özellikler',
    'Attributes',
    'Section heading for fighter attributes.',
  ),
  'ui.points.remaining': GameMessage(
    '{count, plural, one {# puan} other {# puan}}',
    '{count, plural, one {# point} other {# points}}',
    'Remaining attribute points. {count} is the number of points.',
  ),
  'ui.creator.joinLeague': GameMessage(
    'Kıyı Ligi’ne katıl',
    'Join the Coast League',
    'Action that creates the fighter and begins the campaign.',
  ),
  'ui.statHelp.might': GameMessage(
    'Yakın dövüş hasarı',
    'Melee damage',
    'Help text for the Might attribute.',
  ),
  'ui.statHelp.agility': GameMessage(
    'Kaçınma, hareket ve kritik',
    'Evasion, movement, and critical chance',
    'Help text for the Agility attribute.',
  ),
  'ui.statHelp.precision': GameMessage(
    'Silah isabet olasılığı',
    'Weapon hit chance',
    'Help text for the Precision attribute.',
  ),
  'ui.statHelp.vitality': GameMessage(
    'Maksimum sağlık',
    'Maximum health',
    'Help text for the Vitality attribute.',
  ),
  'ui.statHelp.guard': GameMessage(
    'Zırh etkinliği',
    'Armor effectiveness',
    'Help text for the Guard attribute.',
  ),
  'ui.statHelp.stamina': GameMessage(
    'Maksimum efor',
    'Maximum effort',
    'Help text for the Stamina attribute.',
  ),
  'ui.statHelp.arcana': GameMessage(
    'Mana ve büyü',
    'Mana and magic',
    'Help text for the Arcana attribute.',
  ),
  'ui.common.decrease': GameMessage(
    'Azalt',
    'Decrease',
    'Tooltip for reducing an attribute.',
  ),
  'ui.common.increase': GameMessage(
    'Artır',
    'Increase',
    'Tooltip for increasing an attribute.',
  ),

  // Navigation and campaign.
  'ui.nav.league': GameMessage(
    'Lig',
    'League',
    'Bottom navigation destination for the campaign.',
  ),
  'ui.nav.fighter': GameMessage(
    'Dövüşçü',
    'Fighter',
    'Bottom navigation destination for the player character.',
  ),
  'ui.nav.shop': GameMessage(
    'Dükkân',
    'Shop',
    'Bottom navigation destination for the shop.',
  ),
  'ui.nav.contracts': GameMessage(
    'Sözleşme',
    'Contracts',
    'Bottom navigation destination for optional contracts.',
  ),
  'ui.nav.settings': GameMessage(
    'Ayarlar',
    'Settings',
    'Bottom navigation destination for settings.',
  ),
  'ui.campaign.greeting': GameMessage(
    'Merhaba, {name}',
    'Hello, {name}',
    'Greeting on the campaign page. {name} is the fighter’s chosen name.',
  ),
  'ui.campaign.championTitle': GameMessage(
    'Çember senin.',
    'The Circle is yours.',
    'Campaign headline after completing the main campaign.',
  ),
  'ui.campaign.nextDuel': GameMessage(
    'Sıradaki düello',
    'Next duel',
    'Campaign headline before the next encounter.',
  ),
  'ui.campaign.chapter': GameMessage(
    'DEVRE {chapter}  ·  {arena}',
    'ACT {chapter}  ·  {arena}',
    'Arena banner. {chapter} is the act number and {arena} is a localized arena name.',
  ),
  'ui.campaign.complete': GameMessage(
    'Kampanya tamamlandı',
    'Campaign complete',
    'Campaign card title after the final encounter.',
  ),
  'ui.campaign.championsRoadUnlocked': GameMessage(
    'Şampiyonlar Yolu açıldı.',
    'Champions’ Road unlocked.',
    'Notice shown after the main campaign is complete.',
  ),
  'ui.encounter.kind.champion': GameMessage(
    'ŞAMPİYONLUK DÜELLOSU',
    'CHAMPIONSHIP DUEL',
    'Encounter category shown in campaign cards.',
  ),
  'ui.encounter.kind.intermediateFinal': GameMessage(
    'DEVRE FİNALİ',
    'ACT FINAL',
    'Encounter category shown in campaign cards for the four intermediate tournament finals.',
  ),
  'ui.encounter.kind.elite': GameMessage(
    'ELİT DÜELLO',
    'ELITE DUEL',
    'Encounter category shown in campaign cards.',
  ),
  'ui.encounter.kind.main': GameMessage(
    'ANA KAMPANYA',
    'MAIN CAMPAIGN',
    'Encounter category shown in campaign cards.',
  ),
  'ui.campaign.reward': GameMessage(
    'Ödül {gold} Sikke',
    'Reward: {gold} coins',
    'Encounter reward summary. {gold} is the coin amount.',
  ),
  'ui.campaign.epilogueHeading': GameMessage(
    'Epilog · açık kayıtlar',
    'Epilogue · open records',
    'Epilogue panel heading.',
  ),
  'ui.campaign.epilogueBody': GameMessage(
    'Dört devrenin şampiyonları sonuç defterlerini çemberin ortasına bıraktı. Değiştirilen puanlar ve saklanan Sikke hesapları artık herkesin önünde. Lig yeni kurallarla yeniden kurulurken, senin şampiyonluğun kılıç kadar bu açıklığın da simgesi oldu.',
    'The champions of all four acts laid their scorebooks in the center of the Circle. Altered scores and hidden coin accounts are now exposed. As the league rebuilds under new rules, your championship stands for transparency as much as it does for the sword.',
    'Narrative epilogue paragraph shown after the main campaign.',
  ),
  'ui.campaign.postgameIntro': GameMessage(
    'Ustalık sınamaları açıldı: sekiz rakip varyantı, ayrı seri ilerlemesi ve ek Sikke/XP üretmeyen tekrarlar.',
    'Mastery trials are open: eight rival variants, a separate run, and replays that award no extra coins or XP.',
    'Postgame feature summary; XP is the game abbreviation.',
  ),
  'ui.campaign.progress': GameMessage(
    'Lig yolu  ·  {completed} / 32 düello',
    'League progress  ·  {completed} / 32 duels',
    'Campaign progress label. {completed} is the number of completed main duels.',
  ),
  'ui.campaign.levelXp': GameMessage(
    'Seviye {level}  ·  {xp} XP',
    'Level {level}  ·  {xp} XP',
    'Campaign level and experience summary.',
  ),
  'ui.campaign.points': GameMessage(
    '{count, plural, one {# puan} other {# puan}}',
    '{count, plural, one {# point} other {# points}}',
    'Unspent attribute point count.',
  ),
  'ui.intermission.pending': GameMessage(
    'Ara turnuva kararı bekliyor',
    'Intermission choice pending',
    'Campaign card heading while an intermission decision remains unclaimed.',
  ),
  'ui.intermission.heading': GameMessage(
    'Turnuva arası karar',
    'Between tournaments',
    'Title for the one-time choice after selected tournament finals.',
  ),
  'ui.intermission.artDescription': GameMessage(
    '{encounter}. düello sonrası hazırlık sahnesi',
    'Preparation scene after duel {encounter}',
    'Accessible description of the chapter-specific intermission illustration.',
  ),
  'ui.intermission.body': GameMessage(
    '{encounter}. düellonun ardından kısa bir hazırlık fırsatın var. Ödülünü seç; karar kaydedilir ve tekrar alınamaz.',
    'After duel {encounter}, you have a brief chance to prepare. Choose a reward; the choice is saved and cannot be claimed again.',
    '{encounter} is the completed campaign duel number.',
  ),
  'ui.story.evidence.pending': GameMessage(
    'Yeni lig kanıtı',
    'New league evidence',
    'Campaign card heading for unread story evidence.',
  ),
  'ui.story.evidence.open': GameMessage(
    'Kanıtı oku',
    'Read evidence',
    'Opens an unread story evidence card.',
  ),
  'ui.story.evidence.close': GameMessage(
    'Kayda ekle ve kapat',
    'Add to record and close',
    'Marks the story evidence as seen and dismisses the card.',
  ),
  'story.evidence.E04.title': GameMessage(
    'Ödül defterindeki tutarsız mühür',
    'The mismatched prize seal',
    'Title for the first story evidence card.',
  ),
  'story.evidence.E04.body': GameMessage(
    'Turnuva defterindeki mühür, yazılı galibiyet sayısıyla uyuşmuyor. Bu farkı kayda geçir.',
    'The tournament ledger seal does not match its written win count. Record the discrepancy.',
    'Narrative text for the first story evidence card.',
  ),
  'story.evidence.E12.title': GameMessage(
    'İkinci defter aynı farkı gösteriyor',
    'A second ledger confirms it',
    'Title for the second story evidence card.',
  ),
  'story.evidence.E12.body': GameMessage(
    'Ocak vardiyasının bağımsız kayıtları da aynı ödül sayısının değiştirildiğini gösteriyor.',
    'Independent forge-shift records show that the same prize count was altered.',
    'Narrative text for the second story evidence card.',
  ),
  'story.evidence.E20.title': GameMessage(
    'Değiştirilen işaretler tekrar ediyor',
    'The marks repeat',
    'Title for the third story evidence card.',
  ),
  'story.evidence.E20.body': GameMessage(
    'Üç ayrı turnuva defterinde aynı mühür izi ve düzeltilmiş sayım var. Bu artık bir örüntü.',
    'Three tournament ledgers share the same seal mark and corrected count. This is a pattern.',
    'Narrative text for the third story evidence card.',
  ),
  'story.evidence.E28.title': GameMessage(
    'Kanıtlar kamuya açıklandı',
    'The evidence goes public',
    'Title for the fourth story evidence card.',
  ),
  'story.evidence.E28.body': GameMessage(
    'Kayıtlar birleştirilince şampiyon sonuçlarının önceden değiştirildiği ortaya çıkıyor.',
    'Together, the records show that champion results were altered in advance.',
    'Narrative text for the fourth story evidence card.',
  ),
  'ui.intermission.chooseStat': GameMessage(
    'Geliştirilecek özellik',
    'Attribute to train',
    'Label for selecting the attribute that receives the training point.',
  ),
  'ui.intermission.training': GameMessage(
    'Antrenman · {stat} +1',
    'Training · {stat} +1',
    '{stat} is the localized name of the selected attribute.',
  ),
  'ui.intermission.sponsorship': GameMessage(
    'Sponsorluk · +{gold} Sikke',
    'Sponsorship · +{gold} coins',
    '{gold} is the one-time currency reward for this decision.',
  ),
  'ui.intermission.later': GameMessage(
    'Daha sonra seç',
    'Choose later',
    'Closes the decision dialog; the campaign page keeps the choice available.',
  ),
  'ui.intermission.choose': GameMessage(
    'Seçimi onayla',
    'Confirm choice',
    'Accessible button label that commits the selected intermission reward.',
  ),
  'ui.campaign.enterDuel': GameMessage(
    'Düelloya gir',
    'Enter duel',
    'Button to open the next campaign encounter.',
  ),
  'ui.campaign.championsRoad': GameMessage(
    'Şampiyonlar Yolu',
    'Champions’ Road',
    'Postgame challenge series name; preserve the feature name consistently.',
  ),
  'ui.campaign.map': GameMessage(
    'Devre haritası',
    'Act map',
    'Heading above the campaign encounter list.',
  ),
  'ui.campaign.nextKey': GameMessage(
    'Sıradaki: {key}',
    'Next: {key}',
    'Shows the encounter ID of the next duel.',
  ),
  'ui.campaign.endKey': GameMessage(
    'SON',
    'END',
    'Compact campaign map label when all main encounters are complete.',
  ),
  'ui.campaign.masteryTrials': GameMessage(
    'Ustalık sınamaları',
    'Mastery trials',
    'Heading for postgame encounters.',
  ),
  'ui.campaign.trial': GameMessage(
    'Sınama {stage}',
    'Trial {stage}',
    'Postgame trial number.',
  ),
  'ui.campaign.chapterTitle.1': GameMessage(
    'Kül Rıhtımı',
    'Ash Quay',
    'Name of campaign act one.',
  ),
  'ui.campaign.chapterTitle.2': GameMessage(
    'Kor Ocağı',
    'Ember Forge',
    'Name of campaign act two.',
  ),
  'ui.campaign.chapterTitle.3': GameMessage(
    'Fırtına ve Gelgit',
    'Storm and Tide',
    'Name of campaign act three.',
  ),
  'ui.campaign.chapterTitle.4': GameMessage(
    'Taç Devresi',
    'Crown Circuit',
    'Name of campaign act four.',
  ),
  'ui.campaign.chapterHeading': GameMessage(
    'DEVRE {chapter}  ·  {title}',
    'ACT {chapter}  ·  {title}',
    'Campaign act heading.',
  ),
  'ui.campaign.encountersComplete': GameMessage(
    '{completed} / 8 tamamlandı',
    '{completed} / 8 complete',
    'Act completion count.',
  ),
  'ui.audience.crestUnlocked': GameMessage(
    'Devre arması açıldı',
    'Act crest unlocked',
    'Status shown when the audience score unlocks an act crest.',
  ),
  'ui.audience.scoreTitle': GameMessage(
    'Seyirci Notu',
    'Audience score',
    'Heading for the optional audience scoring system.',
  ),
  'ui.audience.cosmeticReward': GameMessage(
    'Kozmetik ödül · ana maçlar toplamı',
    'Cosmetic reward · total from main matches',
    'Audience score reward explanation.',
  ),
  'ui.audience.crestThreshold': GameMessage(
    '16 puanda kozmetik arma açılır',
    'Reach 16 points to unlock a cosmetic crest',
    'Audience score threshold explanation.',
  ),
  'ui.encounter.complete': GameMessage(
    'BİTTİ',
    'DONE',
    'Badge on a completed encounter.',
  ),
  'ui.fighter.heading': GameMessage(
    'Ligin dövüşçüsü',
    'Your league fighter',
    'Heading on the fighter page.',
  ),
  'ui.fighter.level': GameMessage(
    'SEVİYE {level}',
    'LEVEL {level}',
    'Player level badge.',
  ),
  'ui.resource.health': GameMessage(
    'SAĞLIK',
    'HEALTH',
    'Health resource label.',
  ),
  'ui.resource.effort': GameMessage('EFOR', 'EFFORT', 'Effort resource label.'),
  'ui.resource.mana': GameMessage('MANA', 'MANA', 'Mana resource label.'),
  'ui.fighter.resetStats.title': GameMessage(
    'Özellikleri sıfırla?',
    'Reset attributes?',
    'Confirmation dialog title for resetting attributes.',
  ),
  'ui.fighter.resetStats.body': GameMessage(
    'Dağıttığın puanlar geri verilir ve yeniden harcanabilir.',
    'Your spent points will be refunded and can be reassigned.',
    'Confirmation dialog body for resetting attributes.',
  ),
  'ui.common.cancel': GameMessage(
    'Vazgeç',
    'Cancel',
    'Dialog action that dismisses without applying the change.',
  ),
  'ui.common.reset': GameMessage(
    'Sıfırla',
    'Reset',
    'Confirmation action that resets a value or campaign.',
  ),
  'ui.common.use': GameMessage(
    'Kullan',
    'Use',
    'Action to apply a selected item or attribute allocation.',
  ),
  'ui.fighter.pointsToSpend': GameMessage(
    '{count} dağıtılacak',
    '{count} to spend',
    'Unspent attribute points available for allocation.',
  ),
  'ui.fighter.spendPoint': GameMessage(
    'Puan harca',
    'Spend point',
    'Tooltip for spending an attribute point.',
  ),
  'ui.fighter.equipment': GameMessage(
    'Ekipman',
    'Equipment',
    'Heading for equipped gear.',
  ),
  'ui.fighter.inventoryCount': GameMessage(
    'Envanter: {count}',
    'Inventory: {count}',
    'Number of owned campaign items.',
  ),
  'ui.gear.melee': GameMessage(
    'Yakın dövüş',
    'Melee',
    'Gear slot label for a melee weapon.',
  ),
  'ui.gear.ranged': GameMessage(
    'Menzilli',
    'Ranged',
    'Gear slot label for a ranged weapon.',
  ),
  'ui.gear.head': GameMessage(
    'Başlık',
    'Headgear',
    'Gear slot label for head armor.',
  ),
  'ui.gear.body': GameMessage(
    'Gövde',
    'Body',
    'Gear slot label for body armor.',
  ),
  'ui.gear.boots': GameMessage('Çizme', 'Boots', 'Gear slot label for boots.'),
  'ui.gear.talisman': GameMessage(
    'Tılsım',
    'Talisman',
    'Gear slot label for a talisman.',
  ),
  'ui.gear.starting': GameMessage(
    'Başlangıç ekipmanı',
    'Starting gear',
    'Placeholder displayed when no item is equipped.',
  ),
  'ui.fighter.salveCount': GameMessage(
    'Merhem {count}/3',
    'Salve {count}/3',
    'Number of healing salves carried.',
  ),
  'ui.fighter.tonicCount': GameMessage(
    'Toniği {count}/3',
    'Tonic {count}/3',
    'Number of effort tonics carried.',
  ),
  'ui.fighter.learnedSpells': GameMessage(
    'Öğrenilen büyüler: {count}/6',
    'Spells learned: {count}/6',
    'Number of spells learned.',
  ),
  'ui.fighter.masteryTree': GameMessage(
    'Ustalık ağacı',
    'Mastery tree',
    'Heading for the mastery tree.',
  ),
  'ui.fighter.masteryPoints': GameMessage(
    '{count, plural, one {# puan} other {# puan}}',
    '{count, plural, one {# point} other {# points}}',
    'Number of unspent mastery points.',
  ),

  // Shop, challenge, and settings screens.
  'ui.shop.title': GameMessage(
    'Lig dükkânı',
    'League shop',
    'Shop screen title.',
  ),
  'ui.shop.catalog': GameMessage(
    'Devre {act} kataloğu  ·  Harcadığın Sikke maç ödüllerinden kazanılır.',
    'Act {act} catalog  ·  Spend coins earned from duel rewards.',
    'Shop catalog summary; Sikke is the in-game currency.',
  ),
  'ui.filter.all': GameMessage(
    'Hepsi',
    'All',
    'Shop filter showing every category.',
  ),
  'ui.filter.weapon': GameMessage('Silah', 'Weapons', 'Shop category filter.'),
  'ui.filter.armor': GameMessage('Zırh', 'Armor', 'Shop category filter.'),
  'ui.filter.talisman': GameMessage(
    'Tılsım',
    'Talismans',
    'Shop category filter.',
  ),
  'ui.filter.magic': GameMessage('Büyü', 'Spells', 'Shop category filter.'),
  'ui.filter.supplies': GameMessage(
    'Sarf',
    'Supplies',
    'Shop category filter.',
  ),
  'ui.shop.learnableSkills': GameMessage(
    'Öğrenilebilir yetenekler',
    'Learnable skills',
    'Heading for spells available in the shop.',
  ),
  'ui.shop.suppliesBelt': GameMessage(
    'Sarf kuşağı',
    'Supply belt',
    'Heading for consumable items.',
  ),
  'ui.shop.bow': GameMessage('Yay', 'Bow', 'Item category badge for bows.'),
  'ui.shop.power': GameMessage(
    '{power} güç',
    '{power} power',
    'Item power stat summary.',
  ),
  'ui.shop.armorValue': GameMessage(
    '{armor} zırh',
    '{armor} armor',
    'Item armor stat summary.',
  ),
  'ui.shop.itemLevelPrice': GameMessage(
    'Seviye {level}  ·  {price} Sikke',
    'Level {level}  ·  {price} coins',
    'Item level and price.',
  ),
  'ui.shop.minimumAttribute': GameMessage(
    '{attribute} {value} gerekli.',
    '{attribute} {value} required.',
    'Minimum attribute required to buy or equip this item.',
  ),
  'ui.shop.equipped': GameMessage(
    'Takılı',
    'Equipped',
    'Button label when an item is already equipped.',
  ),
  'ui.shop.equip': GameMessage(
    'Kuşan',
    'Equip',
    'Button label to equip an owned item.',
  ),
  'ui.shop.buy': GameMessage('Al', 'Buy', 'Button label to buy an item.'),
  'ui.shop.resaleTitle': GameMessage(
    'Ekipman satışı',
    'Sell gear',
    'Heading above owned gear available for resale.',
  ),
  'ui.shop.resaleInfo': GameMessage(
    'Kuşanılmamış ekipmanını alış fiyatının yarısına satabilirsin.',
    'Sell unequipped gear for half its purchase price.',
    'Explains which gear can be sold and how its resale value is calculated.',
  ),
  'ui.shop.resalePrice': GameMessage(
    '{price} Sikke',
    '{price} coins',
    'Coin amount returned by selling this gear item.',
  ),
  'ui.shop.sell': GameMessage('Sat', 'Sell', 'Button label to sell an item.'),
  'ui.shop.saleEquipped': GameMessage(
    'Takılı',
    'Equipped',
    'Disabled sale state for an item that is currently equipped.',
  ),
  'ui.shop.saleSuccess': GameMessage(
    '{price} Sikke envanterine eklendi.',
    '{price} coins added to your balance.',
    'Confirmation shown after gear is sold.',
  ),
  'ui.shop.saleRejected': GameMessage(
    'Bu ekipman satılamadı.',
    'This gear could not be sold.',
    'Message shown when a sale is rejected.',
  ),
  'ui.shop.spellCost': GameMessage(
    '{description} · {cost} mana',
    '{description} · {cost} mana',
    'Spell effect and mana cost; preserve the supplied description.',
  ),
  'ui.shop.actPrice': GameMessage(
    'Devre {act} · {cost} Sikke',
    'Act {act} · {cost} coins',
    'Spell act and price.',
  ),
  'ui.shop.learned': GameMessage(
    'Öğrenildi',
    'Learned',
    'Button state for a spell already learned.',
  ),
  'ui.shop.learn': GameMessage(
    'Öğren',
    'Learn',
    'Button label to learn a spell.',
  ),
  'ui.shop.healingSalve': GameMessage(
    'Şifa merhemi',
    'Healing salve',
    'Consumable item name.',
  ),
  'ui.shop.effortTonic': GameMessage(
    'Efor toniği',
    'Effort tonic',
    'Consumable item name.',
  ),
  'ui.shop.salveDescription': GameMessage(
    'Maksimum sağlığın %20’sini yeniler.',
    'Restores 20% of your maximum health.',
    'Healing salve effect description.',
  ),
  'ui.shop.tonicDescription': GameMessage(
    '10 efor yeniler.',
    'Restores 10 effort.',
    'Effort tonic effect description.',
  ),
  'ui.shop.inventoryPrice': GameMessage(
    'Çantada {count}/3 · {price} Sikke',
    'In bag {count}/3 · {price} coins',
    'Consumable inventory and price.',
  ),
  'ui.shop.purchase': GameMessage(
    'Satın al',
    'Purchase',
    'Button label for buying a consumable.',
  ),
  'ui.challenge.title': GameMessage(
    'Ek sınamalar',
    'Extra challenges',
    'Challenges screen title.',
  ),
  'ui.challenge.intro': GameMessage(
    'Ana ilerlemeyi değiştirmeyen, ilk tamamlamada sabit ödül veren lig sözleşmeleri.',
    'League contracts that do not affect main progress and grant a fixed reward on first completion.',
    'Challenges screen explanation.',
  ),
  'ui.challenge.championsRoadIntro': GameMessage(
    'Finalden sonra açılan sekiz ayrı ustalık maçı. Tekrarlar Sikke veya deneyim kazandırmaz.',
    'Eight mastery duels unlocked after the finale. Replays award no coins or experience.',
    'Postgame challenge description.',
  ),
  'ui.challenge.completeCount': GameMessage(
    '{completed} / 8 tamamlandı',
    '{completed} / 8 complete',
    'Number of completed Champions’ Road trials.',
  ),
  'ui.challenge.replaySeries': GameMessage(
    'Seriyi yeniden oyna',
    'Replay series',
    'Button to restart a completed challenge series.',
  ),
  'ui.challenge.nextTrial': GameMessage(
    'Sonraki sınama · {stage}',
    'Next trial · {stage}',
    'Button to start the next postgame trial.',
  ),
  'ui.challenge.locked': GameMessage(
    'Şampiyonlar Yolu finalden sonra açılacak.',
    'Champions’ Road unlocks after the finale.',
    'Notice shown while the postgame series is locked.',
  ),
  'ui.contract.reward': GameMessage(
    'İlk tamamlamada {reward} Sikke',
    '{reward} coins on first completion',
    'Contract reward; paid only the first time.',
  ),
  'ui.contract.replay': GameMessage(
    'Tekrar oyna',
    'Replay',
    'Tooltip for a completed contract.',
  ),
  'ui.contract.enter': GameMessage(
    'Sözleşmeye gir',
    'Enter contract',
    'Tooltip for starting a contract.',
  ),
  'ui.settings.title': GameMessage(
    'Ayarlar',
    'Settings',
    'Settings screen title.',
  ),
  'ui.settings.sfx': GameMessage(
    'Ses efektleri',
    'Sound effects',
    'Audio settings toggle.',
  ),
  'ui.settings.sfxDescription': GameMessage(
    'Dövüş ve arayüz efektleri',
    'Combat and interface effects',
    'Audio settings explanation.',
  ),
  'ui.settings.musicVolume': GameMessage(
    'Müzik ve arena ambiyansı',
    'Music and arena ambience',
    'Master level for music tracks and arena ambience loops.',
  ),
  'ui.settings.sfxVolume': GameMessage(
    'Dövüş ve arayüz sesleri',
    'Combat and interface sounds',
    'Independent level for sound effects.',
  ),
  'ui.settings.vibration': GameMessage(
    'Titreşim',
    'Vibration',
    'Optional battle haptics setting.',
  ),
  'ui.settings.vibrationDescription': GameMessage(
    'İsabet, gard ve sonuçlarda kısa titreşim',
    'Short haptics for hits, guarding and results',
    'Explains the optional battle vibration feedback.',
  ),
  'ui.settings.reduceMotion': GameMessage(
    'Hareketi azalt',
    'Reduce motion',
    'Accessibility setting for reduced motion.',
  ),
  'ui.settings.reduceMotionDescription': GameMessage(
    'Savaş geçişleri sadeleşir',
    'Simplifies battle transitions',
    'Reduced-motion setting explanation.',
  ),
  'ui.settings.language': GameMessage(
    'Dil',
    'Language',
    'Language preference setting.',
  ),
  'ui.settings.turkish': GameMessage(
    'Türkçe',
    'Türkçe',
    'Language name; keep the native language name.',
  ),
  'ui.settings.english': GameMessage('English', 'English', 'Language name.'),
  'ui.settings.campaignSave': GameMessage(
    'Kampanya kaydı',
    'Campaign save',
    'Settings section heading for campaign data.',
  ),
  'ui.settings.campaignSummary': GameMessage(
    '{name} · Seviye {level} · {count, plural, one {# ana düello} other {# ana düello}}',
    '{name} · Level {level} · {count, plural, one {# main duel} other {# main duels}}',
    'Saved campaign summary; placeholders come from the player save.',
  ),
  'ui.settings.resetCampaign': GameMessage(
    'Kampanyayı sıfırla',
    'Reset campaign',
    'Button that clears campaign progress.',
  ),
  'ui.settings.deleteSaveTitle': GameMessage(
    'Kayıt silinsin mi?',
    'Delete save?',
    'Confirmation dialog title for clearing the campaign.',
  ),
  'ui.settings.deleteSaveBody': GameMessage(
    'Dövüşçü, Sikkeler ve bütün ilerleme bu cihazdan kaldırılacak.',
    'Your fighter, coins, and all progress will be removed from this device.',
    'Confirmation dialog body for clearing the campaign.',
  ),
  'ui.settings.about': GameMessage(
    'Kül Çemberi',
    'Kül Çemberi',
    'Game name in the about section; keep the established brand name.',
  ),
  'ui.settings.aboutBody': GameMessage(
    'Özgün, çevrimdışı arena RPG. Kayıt bu cihazda saklanır. Savaş ve kampanya ilerlemesi internet bağlantısı gerektirmez.',
    'An original, offline arena RPG. Your save stays on this device. Battles and campaign progress do not require an internet connection.',
    'About text describing offline play and local saves.',
  ),

  // Battle briefing, combat, and result dialogs.
  'ui.result.contractReward': GameMessage(
    '{reward} Sikke sözleşme ödülü.',
    '{reward} coins earned from the contract.',
    'Victory reward message for a contract.',
  ),
  'ui.result.encounterPayout': GameMessage(
    'Bu düelloda {gold} Sikke ve {xp} XP kazandın.',
    'You earned {gold} coins and {xp} XP in this duel.',
    'Campaign payout awarded by the duel that just ended.',
  ),
  'ui.result.replayNoReward': GameMessage(
    'Bu tekrar yeni bir ödül vermedi.',
    'This replay granted no new reward.',
    'Shown when replaying completed content that does not pay out again.',
  ),
  'ui.result.contractFailed': GameMessage(
    'Sözleşme koşulu tamamlanmadı; ana maç ödülleri korunur.',
    'The contract condition was not met; main duel rewards are unchanged.',
    'Result message when contract objectives are not met.',
  ),
  'ui.result.postgameNoReward': GameMessage(
    'Seri ilerlemesi kaydedildi. Bu maç Sikke veya XP vermez.',
    'Series progress saved. This duel awards no coins or XP.',
    'Postgame result message; XP is the game abbreviation.',
  ),
  'ui.result.encounterReward': GameMessage(
    '{gold} Sikke ve {xp} XP ödülü bir kez verilir.',
    '{gold} coins and {xp} XP awarded once.',
    'Campaign victory reward message.',
  ),
  'ui.result.lossSupport': GameMessage(
    'İlk yenilgi desteği verildi. Kazandığında kalan ödülü alırsın.',
    'First-loss support granted. You can claim the remaining reward when you win.',
    'Result message when first-loss support has already been granted.',
  ),
  'ui.result.lossSupportAdded': GameMessage(
    'İlk yenilgi desteği hesabına eklendi.',
    'First-loss support has been added to your account.',
    'Result message when first-loss support is granted.',
  ),
  'ui.result.victory': GameMessage(
    'Zafer',
    'Victory',
    'Battle result title for a won duel.',
  ),
  'ui.result.defeat': GameMessage(
    'Yenilgi',
    'Defeat',
    'Battle result title for a lost duel.',
  ),
  'ui.result.encounterTurns': GameMessage(
    '{encounter} · {turns, plural, one {# tur} other {# tur}}',
    '{encounter} · {turns, plural, one {# turn} other {# turns}}',
    'Encounter name and number of turns in the battle result.',
  ),
  'ui.audience.report': GameMessage(
    'SEYİRCİ NOTU',
    'AUDIENCE SCORE',
    'Battle result summary heading.',
  ),
  'ui.audience.bestScore': GameMessage(
    'En iyi not: {score} / 3',
    'Best score: {score} / 3',
    'Best audience score recorded for a campaign duel.',
  ),
  'ui.audience.notCampaign': GameMessage(
    'Bu maç notu ana kampanya arması için kaydedilmez.',
    'This score does not count toward the main campaign crest.',
    'Explains why a challenge result does not count toward campaign crests.',
  ),
  'ui.result.epilogueUnlocked': GameMessage(
    'Epilog açıldı. Şampiyonlar Yolu lige eklendi.',
    'Epilogue unlocked. Champions’ Road has been added to the league.',
    'Notice shown after defeating the final champion.',
  ),
  'ui.common.retry': GameMessage(
    'Yeniden dene',
    'Retry',
    'Button to replay a duel after a loss or incomplete objective.',
  ),
  'ui.result.returnLeague': GameMessage(
    'Lige dön',
    'Return to league',
    'Button to return to the campaign after victory.',
  ),
  'ui.result.leaveDuel': GameMessage(
    'Düelloyu bırak',
    'Leave duel',
    'Button to leave the duel after defeat.',
  ),
  'ui.battle.leaveTitle': GameMessage(
    'Düellodan ayrıl?',
    'Leave the duel?',
    'Confirmation dialog title when leaving an active duel.',
  ),
  'ui.battle.leaveBody': GameMessage(
    'Bu maçtan çıkarsan savaş yeniden başlar. Kampanya ilerlemen etkilenmez.',
    'If you leave this duel, it will restart. Your campaign progress will not be affected.',
    'Confirmation dialog body when leaving an active duel.',
  ),
  'ui.common.continue': GameMessage(
    'Devam et',
    'Continue',
    'Dialog action that keeps the current duel open.',
  ),
  'ui.common.leave': GameMessage(
    'Ayrıl',
    'Leave',
    'Dialog action that exits the current duel.',
  ),
  'ui.battle.contractReward': GameMessage(
    '{reward} Sikke · sözleşme koşulu ile alınır',
    '{reward} coins · earned by meeting the contract condition',
    'Reward summary shown in the battle briefing for a contract.',
  ),
  'ui.battle.noPostgameReward': GameMessage(
    'Sikke veya XP vermez · ustalık serisi ilerler',
    'No coins or XP · advances the mastery series',
    'Reward summary shown for a postgame trial.',
  ),
  'ui.battle.encounterReward': GameMessage(
    '{gold} Sikke · {xp} XP',
    '{gold} coins · {xp} XP',
    'Reward summary shown in the battle briefing.',
  ),
  'ui.battle.briefing': GameMessage(
    'DÜELLO BRİFİNGİ',
    'DUEL BRIEFING',
    'Heading on the pre-battle briefing screen.',
  ),
  'ui.battle.arenaState': GameMessage(
    'Meydanın durumu',
    'Arena conditions',
    'Heading for arena conditions in the briefing.',
  ),
  'ui.battle.briefingEncounter': GameMessage(
    '{story} {mood}. Her turda tek hamle seç; rakibin niyeti önceden gösterilir.',
    '{story} {mood}. Choose one action each turn; your rival’s intent is shown in advance.',
    'Briefing narrative. {story} and {mood} are localized content.',
  ),
  'ui.battle.briefingFallback': GameMessage(
    '{mood}. Rakibin görünen niyetini takip et; her turda tek hamle seçebilirsin.',
    '{mood}. Watch your rival’s displayed intent and choose one action each turn.',
    'Briefing narrative when the encounter has no custom story.',
  ),
  'ui.battle.firstWinReward': GameMessage(
    'İlk zafer ödülü  ·  {reward}',
    'First-win reward  ·  {reward}',
    'First victory reward summary.',
  ),
  'ui.audience.conditions': GameMessage(
    'Seyirci Notu · 3 açık koşul',
    'Audience score · 3 active conditions',
    'Heading for the optional scoring checklist before a duel.',
  ),
  'ui.battle.audienceHelp': GameMessage(
    'Her koşul bir puan. Ana kampanyada en iyi notlar devre armasını açar; savaş değerlerini ve Sikke ödülünü etkilemez.',
    'Each condition is worth one point. In the main campaign, your best scores unlock act crests; they do not affect combat stats or coin rewards.',
    'Explains the optional audience score checklist.',
  ),
  'ui.battle.start': GameMessage(
    'Düelloya başla',
    'Start duel',
    'Primary action to begin combat from the briefing.',
  ),
  'ui.battle.notFound': GameMessage(
    'Aktif düello bulunamadı.',
    'No active duel found.',
    'Fallback message if the active duel state is missing.',
  ),
  'ui.battle.kind.champion': GameMessage(
    'ŞAMPİYON',
    'CHAMPION',
    'Battle header category for a champion encounter.',
  ),
  'ui.battle.kind.intermediateFinal': GameMessage(
    'DEVRE FİNALİ',
    'ACT FINAL',
    'Battle header category for an intermediate tournament final.',
  ),
  'ui.battle.kind.elite': GameMessage(
    'ELİT DÜELLO',
    'ELITE DUEL',
    'Battle header category for an elite encounter.',
  ),
  'ui.battle.kind.league': GameMessage(
    'LİG DÜELLOSU',
    'LEAGUE DUEL',
    'Battle header category for a regular encounter.',
  ),
  'ui.battle.distancePhase': GameMessage(
    'MESAFE  ·  {distance}  ·  FAZ {phase}/{phases}',
    'RANGE  ·  {distance}  ·  PHASE {phase}/{phases}',
    'Battle arena overlay showing range and phase.',
  ),
  'ui.battle.arenaHazard': GameMessage(
    'ARENA TEHLİKESİ',
    'ARENA HAZARD',
    'Heading above the telegraphed arena hazard.',
  ),
  'ui.battle.opponentIntent': GameMessage(
    'RAKİBİN NİYETİ',
    'RIVAL’S INTENT',
    'Heading above the opponent’s telegraphed action.',
  ),
  'ui.battle.hazardAdvice': GameMessage(
    'Yer değiştir veya gard al.',
    'Move or guard.',
    'Instruction displayed when an arena hazard is telegraphed.',
  ),
  'ui.battle.chooseAction': GameMessage(
    'Hamleni seç',
    'Choose your action',
    'Heading above player combat actions.',
  ),
  'ui.battle.ammo': GameMessage(
    '{count, plural, one {# fişek} other {# fişek}}',
    '{count, plural, one {# arrow} other {# arrows}}',
    'Remaining ammunition badge.',
  ),
  'ui.battle.combatLog': GameMessage(
    'Dövüş günlüğü',
    'Combat log',
    'Heading above recent combat events.',
  ),
  'ui.battle.logEntry': GameMessage(
    '·  {entry}',
    '·  {entry}',
    'A single combat log entry; {entry} is produced by the combat engine.',
  ),
  'ui.battle.turnHint': GameMessage(
    'Tur {turn} · Bir hamle seçince rakip açıklanan niyetini uygular.',
    'Turn {turn} · Your rival carries out the displayed intent after you choose an action.',
    'Hint below the combat log.',
  ),
  'ui.battle.turnShort': GameMessage(
    'T{turn}',
    'T{turn}',
    'Compact turn counter in the battle header.',
  ),
  'ui.battle.error.done': GameMessage(
    'Düello tamamlandı.',
    'This duel is over.',
    'Error shown when an action is attempted after combat has ended.',
  ),
  'ui.battle.error.unavailable': GameMessage(
    'Bu hamle şu anda kullanılamıyor.',
    'That action is unavailable right now.',
    'Error shown when an action cannot currently be used.',
  ),

  // Stable battle presentation messages. Keep placeholders as typed values in BattleEngine.
  'battle.audience.tactics': GameMessage(
    'En az iki farklı taktik yaklaşım kullan',
    'Use at least two different tactical approaches',
    'Audience checklist condition for using multiple action families.',
  ),
  'battle.audience.answerAttack': GameMessage(
    'Gösterilen saldırı niyetine gardla karşılık ver',
    'Guard against a displayed attack intent',
    'Audience checklist condition for guarding against an announced attack.',
  ),
  'battle.audience.avoidHazard': GameMessage(
    'Arena tehlikesinden hasar almadan çık',
    'Avoid damage from the arena hazard',
    'Audience checklist condition for a hazardous arena.',
  ),
  'battle.audience.changeRange': GameMessage(
    'Mesafeyi en az bir kez değiştir',
    'Change range at least once',
    'Audience checklist condition for arenas without a hazard.',
  ),
  'battle.intent.hazard': GameMessage(
    'Arena tehlikesi: yer değiştir veya gard al',
    'Arena hazard: move or guard',
    'Intent message when the arena hazard is about to trigger.',
  ),
  'battle.intent.quick': GameMessage(
    'Hızlı vuruş hazırlıyor',
    'Readies a quick strike',
    'Opponent intent shown before the player acts.',
  ),
  'battle.intent.heavy': GameMessage(
    'Güçlü vuruş hazırlıyor',
    'Readies a heavy strike',
    'Opponent intent shown before the player acts.',
  ),
  'battle.intent.guard': GameMessage(
    'Gard alacak',
    'Will guard',
    'Opponent intent shown before the player acts.',
  ),
  'battle.intent.sweep': GameMessage(
    'Çelme hazırlıyor',
    'Readies a sweep',
    'Opponent intent shown before the player acts.',
  ),
  'battle.intent.bow': GameMessage(
    'Yayını geriyor',
    'Draws a bow',
    'Opponent intent shown before the player acts.',
  ),
  'battle.intent.emberSpear': GameMessage(
    'Köz Mızrağı hazırlıyor',
    'Readies Ember Spear',
    'Opponent intent shown before the player acts.',
  ),
  'battle.intent.ashBurst': GameMessage(
    'Kül Patlaması hazırlıyor',
    'Readies Ash Burst',
    'Opponent intent shown before the player acts.',
  ),
  'battle.intent.tideWard': GameMessage(
    'Siper Dalgası hazırlıyor',
    'Readies Tide Ward',
    'Opponent intent shown before the player acts.',
  ),
  'battle.intent.saltCleanse': GameMessage(
    'Tuz Arındırması hazırlıyor',
    'Readies Salt Cleanse',
    'Opponent intent shown before the player acts.',
  ),
  'battle.intent.swiftBreeze': GameMessage(
    'Çevik Esinti hazırlıyor',
    'Readies Swift Breeze',
    'Opponent intent shown before the player acts.',
  ),
  'battle.intent.shoreStep': GameMessage(
    'Kıyı Sıçrayışı hazırlıyor',
    'Readies Shore Step',
    'Opponent intent shown before the player acts.',
  ),
  'battle.intent.closeDistance': GameMessage(
    'Mesafeyi kapatacak',
    'Will move closer',
    'Opponent intent shown before the player acts.',
  ),
  'battle.intent.openDistance': GameMessage(
    'Geri çekilecek',
    'Will move away',
    'Opponent intent shown before the player acts.',
  ),
  'battle.intent.salve': GameMessage(
    'Şifa merhemi kullanacak',
    'Will use a healing salve',
    'Opponent intent shown before the player acts.',
  ),
  'battle.intent.tonic': GameMessage(
    'Efor toniği kullanacak',
    'Will use an effort tonic',
    'Opponent intent shown before the player acts.',
  ),
  'battle.log.encounterIntro': GameMessage(
    '{opponent} sahaya çıkıyor. Rakip: {archetype}.',
    '{opponent} enters the arena. Rival: {archetype}.',
    'Opening combat log line. {opponent} is the localized rival name; {archetype} is a translated opponent style.',
  ),
  'battle.log.arenaRule': GameMessage(
    'Arena kuralı: {hazard}. Tehlike yaklaşırken yer değiştir.',
    'Arena rule: {hazard}. Move when danger approaches.',
    'Opening combat log line describing the arena hazard.',
  ),
  'battle.log.guard': GameMessage(
    '{actor} gard aldı.',
    '{actor} takes guard.',
    'Combat log line when a fighter guards.',
  ),
  'battle.log.hazardApproaching': GameMessage(
    'Arena tehlikesi yaklaşmakta: sonraki turda yer değiştir veya gard al.',
    'The arena hazard is approaching: move or guard next turn.',
    'Combat log warning before an arena hazard triggers.',
  ),
  'battle.log.closeDistance': GameMessage(
    '{actor} mesafeyi kapatıyor: {range}.',
    '{actor} closes the distance: {range}.',
    'Combat log line when a fighter moves closer.',
  ),
  'battle.log.openDistance': GameMessage(
    '{actor} geri çekiliyor: {range}.',
    '{actor} retreats: {range}.',
    'Combat log line when a fighter moves away.',
  ),
  'battle.log.salve': GameMessage(
    '{actor} şifa merhemi kullandı: +{amount} sağlık.',
    '{actor} uses a healing salve: +{amount} health.',
    'Combat log line for healing. {amount} is restored health.',
  ),
  'battle.log.tonic': GameMessage(
    '{actor} efor toniği kullandı: +{amount} efor.',
    '{actor} uses an effort tonic: +{amount} effort.',
    'Combat log line for an effort tonic.',
  ),
  'battle.log.tideWard': GameMessage(
    '{actor}, {amount} hasar emen bir siper kurdu.',
    '{actor} creates a ward that absorbs {amount} damage.',
    'Combat log line for Tide Ward. {amount} is the shield strength.',
  ),
  'battle.log.saltCleanse': GameMessage(
    '{actor} olumsuz etkiyi arındırdı ve {amount} sağlık kazandı.',
    '{actor} cleanses a negative effect and restores {amount} health.',
    'Combat log line for Salt Cleanse.',
  ),
  'battle.log.swiftBreeze': GameMessage(
    '{actor} çevik esintiyle sonraki hamlesini hazırladı.',
    '{actor} prepares the next action with Swift Breeze.',
    'Combat log line for Swift Breeze.',
  ),
  'battle.log.shoreStep': GameMessage(
    '{actor} kıyı sıçrayışıyla mesafeyi değiştirdi.',
    '{actor} changes range with Shore Step.',
    'Combat log line for Shore Step.',
  ),
  'battle.log.miss': GameMessage(
    '{actor} — {action}: ıskaladı (%{chance}).',
    '{actor} — {action}: misses ({chance}%).',
    'Combat log line for a missed action.',
  ),
  'battle.log.ashBurstHit': GameMessage(
    '{actor}, {action} ile {damage} hasar ve yanma uyguladı.',
    '{actor} deals {damage} damage and applies Burn with {action}.',
    'Combat log line for Ash Burst.',
  ),
  'battle.log.hit': GameMessage(
    '{actor}, {action} ile {damage} hasar verdi (%{chance}).',
    '{actor} deals {damage} damage with {action} ({chance}% hit chance).',
    'Combat log line for a successful attack.',
  ),
  'battle.log.brokenGuard': GameMessage(
    '{target} gardı kırıldı: zırhı bir sonraki tur %20 azalır.',
    '{target}’s guard is broken: armor is reduced by 20% for one turn.',
    'Combat log line when a Sweep applies the one-turn Broken Guard effect.',
  ),
  'battle.log.stagger': GameMessage(
    '{target} sendeledi.',
    '{target} is staggered.',
    'Combat log line when a fighter is staggered.',
  ),
  'battle.log.bleed': GameMessage(
    '{target} kanama etkisi aldı.',
    '{target} is bleeding.',
    'Combat log line when a fighter gains Bleed.',
  ),
  'battle.log.shieldAbsorb': GameMessage(
    '{target} siperi {amount} hasar emdi.',
    '{target}’s ward absorbs {amount} damage.',
    'Combat log line when a shield absorbs damage.',
  ),
  'battle.log.damageOverTime': GameMessage(
    '{actor}: {status} {damage} hasar verdi.',
    '{actor}: {status} deals {damage} damage.',
    'Combat log line for damage from Burn or Bleed.',
  ),
  'battle.log.spellTelegraph': GameMessage(
    '{opponent} büyü hazırlıyor: {action}.',
    '{opponent} prepares a spell: {action}.',
    'Combat log telegraph for an opponent spell.',
  ),
  'battle.log.hazardAvoided': GameMessage(
    'İşaretli arena tehlikesinden zamanında uzaklaştın.',
    'You move clear of the marked arena hazard in time.',
    'Combat log line when the player avoids a hazard.',
  ),
  'battle.log.hazardDamage': GameMessage(
    'Arena tehlikesi {damage} hasar verdi.',
    'The arena hazard deals {damage} damage.',
    'Combat log line for hazard damage.',
  ),
  'battle.log.phaseChange': GameMessage(
    '{opponent} {phase}. faza geçti. İpucu: {archetype} saldırıları güçleniyor.',
    '{opponent} enters phase {phase}. Hint: {archetype} attacks are growing stronger.',
    'Combat log line when a rival enters a new phase.',
  ),
  'battle.log.opponentRangeChange': GameMessage(
    '{opponent} mesafeyi değiştirdi: {range}.',
    '{opponent} changes range: {range}.',
    'Combat log line when the rival changes range.',
  ),
  'battle.log.victory': GameMessage(
    'Zafer! {gold} Sikke ve {xp} deneyim kazanıldı.',
    'Victory! Earned {gold} coins and {xp} XP.',
    'Final combat log line after victory.',
  ),
  'battle.log.defeat': GameMessage(
    'Düello kaybedildi. Kampanya ilerlemen korundu.',
    'Duel lost. Your campaign progress is preserved.',
    'Final combat log line after defeat.',
  ),
  'battle.preview.cost.bow': GameMessage(
    '{effort} efor · {ammo} fişek',
    '{effort} effort · {ammo} arrows',
    'Cost shown on the ranged attack tile.',
  ),
  'battle.preview.cost.mana': GameMessage(
    '{mana} mana',
    '{mana} mana',
    'Cost shown on a spell action tile.',
  ),
  'battle.preview.cost.free': GameMessage(
    'Ücretsiz',
    'Free',
    'Cost shown for a free combat action.',
  ),
  'battle.preview.cost.effort': GameMessage(
    '{effort} efor',
    '{effort} effort',
    'Effort cost shown on an action tile.',
  ),
  'battle.preview.note.bowPenalty': GameMessage(
    'Yakında −15 isabet',
    '−15 accuracy at close range',
    'Range penalty shown on the bow action tile.',
  ),
  'battle.preview.note.sweepArmor': GameMessage(
    'Zırhın %35’ini yok sayar; isabet ederse sonraki tur hedefin zırhını %20 düşürür',
    'Ignores 35% of armor; on hit, reduces the target’s armor by 20% for the next turn',
    'Effect note shown on the Sweep action tile, including its Broken Guard follow-up.',
  ),
  'battle.preview.note.guard': GameMessage(
    'Sonraki hasarı %45 azaltır, 4 efor kazanır',
    'Reduces the next hit by 45% and restores 4 effort',
    'Effect note shown on the Guard action tile.',
  ),

  // Stable model labels shown by the UI.
  'label.stat.might': GameMessage('Kuvvet', 'Might', 'Player attribute name.'),
  'label.stat.agility': GameMessage(
    'Çeviklik',
    'Agility',
    'Player attribute name.',
  ),
  'label.stat.precision': GameMessage(
    'İsabet',
    'Precision',
    'Player attribute name.',
  ),
  'label.stat.vitality': GameMessage(
    'Dayanıklılık',
    'Vitality',
    'Player attribute name.',
  ),
  'label.stat.guard': GameMessage('Savunma', 'Guard', 'Player attribute name.'),
  'label.stat.stamina': GameMessage(
    'Kondisyon',
    'Stamina',
    'Player attribute name.',
  ),
  'label.stat.arcana': GameMessage('Büyü', 'Arcana', 'Player attribute name.'),
  'label.family.shortSword': GameMessage(
    'Kısa kılıç',
    'Short sword',
    'Weapon family label.',
  ),
  'label.family.maul': GameMessage('Tokmak', 'Maul', 'Weapon family label.'),
  'label.family.spear': GameMessage('Mızrak', 'Spear', 'Weapon family label.'),
  'label.family.bow': GameMessage('Yay', 'Bow', 'Weapon family label.'),
  'label.range.close': GameMessage('Yakın', 'Close', 'Combat range label.'),
  'label.range.medium': GameMessage('Orta', 'Medium', 'Combat range label.'),
  'label.range.far': GameMessage('Uzak', 'Far', 'Combat range label.'),
  'label.status.stagger': GameMessage(
    'Sendeleme',
    'Stagger',
    'Combat status label.',
  ),
  'label.status.bleed': GameMessage('Kanama', 'Bleed', 'Combat status label.'),
  'label.status.burn': GameMessage('Yanma', 'Burn', 'Combat status label.'),
  'label.status.brokenGuard': GameMessage(
    'Kırık gard',
    'Broken guard',
    'Combat status label.',
  ),
  'label.action.quick': GameMessage(
    'Hızlı vuruş',
    'Quick strike',
    'Combat action name.',
  ),
  'label.action.heavy': GameMessage(
    'Güçlü vuruş',
    'Heavy strike',
    'Combat action name.',
  ),
  'label.action.guard': GameMessage('Gard al', 'Guard', 'Combat action name.'),
  'label.action.sweep': GameMessage('Çelme', 'Sweep', 'Combat action name.'),
  'label.action.bow': GameMessage(
    'Menzilli atış',
    'Ranged shot',
    'Combat action name.',
  ),
  'label.action.emberSpear': GameMessage(
    'Köz Mızrağı',
    'Ember Spear',
    'Combat spell name.',
  ),
  'label.action.ashBurst': GameMessage(
    'Kül Patlaması',
    'Ash Burst',
    'Combat spell name.',
  ),
  'label.action.tideWard': GameMessage(
    'Siper Dalgası',
    'Tide Ward',
    'Combat spell name.',
  ),
  'label.action.saltCleanse': GameMessage(
    'Tuz Arındırması',
    'Salt Cleanse',
    'Combat spell name.',
  ),
  'label.action.swiftBreeze': GameMessage(
    'Çevik Esinti',
    'Swift Breeze',
    'Combat spell name.',
  ),
  'label.action.shoreStep': GameMessage(
    'Kıyı Sıçrayışı',
    'Shore Step',
    'Combat spell name.',
  ),
  'label.action.closeDistance': GameMessage(
    'Yaklaş',
    'Move closer',
    'Combat movement action.',
  ),
  'label.action.openDistance': GameMessage(
    'Uzaklaş',
    'Move away',
    'Combat movement action.',
  ),
  'label.action.salve': GameMessage(
    'Şifa merhemi',
    'Healing salve',
    'Combat consumable name.',
  ),
  'label.action.tonic': GameMessage(
    'Efor toniği',
    'Effort tonic',
    'Combat consumable name.',
  ),

  // Arena names and mood lines.
  'content.arena.kul.name': GameMessage(
    'Kül Rıhtımı',
    'Ash Quay',
    'Arena proper name.',
  ),
  'content.arena.kul.mood': GameMessage(
    'Fırtınanın başladığı yer',
    'Where the storm begins',
    'Short arena mood line.',
  ),
  'content.arena.kor.name': GameMessage(
    'Kor Ocağı',
    'Ember Forge',
    'Arena proper name.',
  ),
  'content.arena.kor.mood': GameMessage(
    'Her zafer bir bedel ister',
    'Every victory demands a price',
    'Short arena mood line.',
  ),
  'content.arena.firtina.name': GameMessage(
    'Fırtına Gözlemevi',
    'Storm Observatory',
    'Arena proper name.',
  ),
  'content.arena.firtina.mood': GameMessage(
    'Gök bile sonucu izliyor',
    'Even the sky watches the outcome',
    'Short arena mood line.',
  ),
  'content.arena.gelgit.name': GameMessage(
    'Gelgit Amfitiyatrosu',
    'Tide Amphitheater',
    'Arena proper name.',
  ),
  'content.arena.gelgit.mood': GameMessage(
    'Sular çekilince sırlar kalır',
    'When the waters recede, secrets remain',
    'Short arena mood line.',
  ),
  'content.arena.tac.name': GameMessage(
    'Taç Kalesi',
    'Crown Keep',
    'Arena proper name.',
  ),
  'content.arena.tac.mood': GameMessage(
    'Kapıdan yalnızca biri çıkar',
    'Only one leaves through the gate',
    'Short arena mood line.',
  ),
  'content.arena.halka.name': GameMessage(
    'Taç Halkası',
    'Crown Circle',
    'Arena proper name.',
  ),
  'content.arena.halka.mood': GameMessage(
    'Son söz çemberde söylenir',
    'The Circle has the final word',
    'Short arena mood line.',
  ),

  // Main rivals, keyed by stable encounter IDs.
  'content.encounter.M01.name': GameMessage(
    'İskele Kabadayısı',
    'Pier Bruiser',
    'Rival name for encounter M01.',
  ),
  'content.encounter.M01.story': GameMessage(
    'Kıyı Ligi’ne adım at. Kabadayının gardı geniş, ama açık veriyor.',
    'Step into the Coast League. The bruiser leaves a wide opening in his guard.',
    'Encounter M01 story briefing.',
  ),
  'content.encounter.M02.name': GameMessage(
    'Halat Koşucusu',
    'Rope Runner',
    'Rival name for encounter M02.',
  ),
  'content.encounter.M03.name': GameMessage(
    'Kapı Bekçisi',
    'Gatekeeper',
    'Rival name for encounter M03.',
  ),
  'content.encounter.M04.name': GameMessage(
    'Tuz Kahini',
    'Salt Seer',
    'Rival name for encounter M04.',
  ),
  'content.encounter.M04.hazard': GameMessage(
    'Önceden işaretlenmiş dalga',
    'Telegraphed wave',
    'Arena hazard label for encounter M04.',
  ),
  'content.encounter.M05.name': GameMessage(
    'Halatçı Sefa',
    'Sefa the Rigger',
    'Rival name; preserve the personal name Sefa.',
  ),
  'content.encounter.M06.name': GameMessage(
    'Paslı Kanca',
    'Rusty Hook',
    'Rival name for encounter M06.',
  ),
  'content.encounter.M07.name': GameMessage(
    'Fener Bekçisi',
    'Lantern Keeper',
    'Rival name for encounter M07.',
  ),
  'content.encounter.M07.hazard': GameMessage(
    'İşaretli alan',
    'Marked zone',
    'Arena hazard label for encounter M07.',
  ),
  'content.encounter.M08.name': GameMessage(
    'Fener Şampiyonu',
    'Lantern Champion',
    'Rival name for encounter M08.',
  ),
  'content.encounter.M08.story': GameMessage(
    'İlk şampiyon, lig kayıtlarındaki tutarsızlığı fark etmiş.',
    'The first champion noticed inconsistencies in the league records.',
    'Encounter M08 story briefing.',
  ),
  'content.encounter.M09.name': GameMessage(
    'Cüruf Taşıyıcı',
    'Slag Hauler',
    'Rival name for encounter M09.',
  ),
  'content.encounter.M09.hazard': GameMessage(
    'Önceden işaretlenen buhar',
    'Telegraphed steam',
    'Arena hazard label for encounter M09.',
  ),
  'content.encounter.M10.name': GameMessage(
    'Zincirci',
    'Chain Fighter',
    'Rival name for encounter M10.',
  ),
  'content.encounter.M11.name': GameMessage(
    'Örs Muhafızı',
    'Anvil Guard',
    'Rival name for encounter M11.',
  ),
  'content.encounter.M12.name': GameMessage(
    'Sözleşmeli Düellocu',
    'Contract Duelist',
    'Rival name for encounter M12.',
  ),
  'content.encounter.M13.name': GameMessage(
    'Köz Gölgesi',
    'Ember Shadow',
    'Rival name for encounter M13.',
  ),
  'content.encounter.M13.hazard': GameMessage(
    'Önceden işaretlenen buhar',
    'Telegraphed steam',
    'Arena hazard label for encounter M13.',
  ),
  'content.encounter.M14.name': GameMessage(
    'Kızıl Ocak Şefi',
    'Crimson Forge Chief',
    'Rival name for encounter M14.',
  ),
  'content.encounter.M14.hazard': GameMessage(
    'İşaretli buhar',
    'Marked steam',
    'Arena hazard label for encounter M14.',
  ),
  'content.encounter.M15.name': GameMessage(
    'Kükürt Matronu',
    'Sulfur Matron',
    'Rival name for encounter M15.',
  ),
  'content.encounter.M16.name': GameMessage(
    'Pirinç Muhafız',
    'Brass Guardian',
    'Rival name for encounter M16.',
  ),
  'content.encounter.M16.story': GameMessage(
    'Ocak işçileri, sonuçların yönetim tarafından değiştirildiğini kanıtlayan defteri verir.',
    'The forge workers hand you the ledger proving that league officials altered the results.',
    'Encounter M16 story briefing.',
  ),
  'content.encounter.M17.name': GameMessage(
    'Menzil Avcısı',
    'Range Hunter',
    'Rival name for encounter M17.',
  ),
  'content.encounter.M18.name': GameMessage(
    'Ayna Kılıç',
    'Mirrorblade',
    'Rival name for encounter M18.',
  ),
  'content.encounter.M19.name': GameMessage(
    'Gelgit Mührücüsü',
    'Tide Binder',
    'Rival name for encounter M19.',
  ),
  'content.encounter.M19.hazard': GameMessage(
    'İşaretli gelgit alanı',
    'Marked tide zone',
    'Arena hazard label for encounter M19.',
  ),
  'content.encounter.M20.name': GameMessage(
    'Fırtına Avcısı',
    'Storm Hunter',
    'Rival name for encounter M20.',
  ),
  'content.encounter.M21.name': GameMessage(
    'Rüzgâr Seyircisi',
    'Windwatcher',
    'Rival name for encounter M21.',
  ),
  'content.encounter.M22.name': GameMessage(
    'Kıyı Orakçısı',
    'Coast Reaper',
    'Rival name for encounter M22.',
  ),
  'content.encounter.M23.name': GameMessage(
    'Gelgit Yargıcı',
    'Tide Judge',
    'Rival name for encounter M23.',
  ),
  'content.encounter.M23.hazard': GameMessage(
    'Açıklanan gelgit sırası',
    'Telegraphed tide sequence',
    'Arena hazard label for encounter M23.',
  ),
  'content.encounter.M24.name': GameMessage(
    'Gözlemci Başrahip',
    'Observer High Priest',
    'Rival name for encounter M24.',
  ),
  'content.encounter.M24.story': GameMessage(
    'Şampiyonlar da aynı düzenin baskısı altında. Kanıtlar final turnuvasına taşınıyor.',
    'The champions are under pressure from the same system. The evidence is headed to the final tournament.',
    'Encounter M24 story briefing.',
  ),
  'content.encounter.M25.name': GameMessage(
    'Taç Muhafızı',
    'Crown Guard',
    'Rival name for encounter M25.',
  ),
  'content.encounter.M26.name': GameMessage(
    'Gölge Düellocu',
    'Shadow Duelist',
    'Rival name for encounter M26.',
  ),
  'content.encounter.M27.name': GameMessage(
    'Sancak Cadısı',
    'Banner Witch',
    'Rival name for encounter M27.',
  ),
  'content.encounter.M28.name': GameMessage(
    'Demir Cellat',
    'Iron Executioner',
    'Rival name for encounter M28.',
  ),
  'content.encounter.M29.name': GameMessage(
    'Tahtsız Varis',
    'Heir Without a Throne',
    'Rival name for encounter M29.',
  ),
  'content.encounter.M30.name': GameMessage(
    'Kül Komutanı',
    'Ash Commander',
    'Rival name for encounter M30.',
  ),
  'content.encounter.M31.name': GameMessage(
    'Mühür Kırıcı',
    'Sealbreaker',
    'Rival name for encounter M31.',
  ),
  'content.encounter.M32.name': GameMessage(
    'Çember Ustası',
    'Circle Master',
    'Rival name for encounter M32.',
  ),
  'content.encounter.M32.story': GameMessage(
    'Final şampiyonu lig yönetimiyle bağını kesiyor. Çember artık oyuncuların.',
    'The final champion breaks ties with league officials. The Circle now belongs to its fighters.',
    'Encounter M32 story briefing.',
  ),

  'content.archetype.vurucu': GameMessage(
    'vurucu',
    'striker',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.çevik': GameMessage(
    'çevik',
    'agile',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.kalkanlı': GameMessage(
    'kalkanlı',
    'shielded',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.mühürcü': GameMessage(
    'mühürcü',
    'binder',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.menzilci': GameMessage(
    'menzilci',
    'ranged fighter',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.karşı hamleci': GameMessage(
    'karşı hamleci',
    'counterattacker',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.alan kontrolcüsü': GameMessage(
    'alan kontrolcüsü',
    'zone controller',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.şampiyon': GameMessage(
    'şampiyon',
    'champion',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.ağır saldırgan': GameMessage(
    'ağır saldırgan',
    'heavy attacker',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.durum etkili': GameMessage(
    'durum etkili',
    'status inflicter',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.zırhlı': GameMessage(
    'zırhlı',
    'armored',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.karma': GameMessage(
    'karma',
    'hybrid',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.karşı saldırgan': GameMessage(
    'karşı saldırgan',
    'counter-striker',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.büyücü': GameMessage(
    'büyücü',
    'spellcaster',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.mızrakçı': GameMessage(
    'mızrakçı',
    'spearfighter',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.şampiyon mühürcü': GameMessage(
    'şampiyon mühürcü',
    'champion binder',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.ağır vurucu': GameMessage(
    'ağır vurucu',
    'heavy hitter',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.çevik karma': GameMessage(
    'çevik karma',
    'agile hybrid',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.karma şampiyon': GameMessage(
    'karma şampiyon',
    'hybrid champion',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),
  'content.archetype.final şampiyonu': GameMessage(
    'final şampiyonu',
    'final champion',
    'Opponent fighting style shown in encounter cards and battle logs.',
  ),

  // Contract names and objective descriptions.
  'content.contract.C1-A.title': GameMessage(
    'Temiz düello',
    'Clean duel',
    'Contract title.',
  ),
  'content.contract.C1-A.description': GameMessage(
    'Durum etkisi almadan kazan.',
    'Win without receiving a status effect.',
    'Contract objective.',
  ),
  'content.contract.C1-B.title': GameMessage(
    'Kısa kılıç ustalığı',
    'Short-sword mastery',
    'Contract title.',
  ),
  'content.contract.C1-B.description': GameMessage(
    'Kısa kılıçla kazan.',
    'Win with a short sword.',
    'Contract objective.',
  ),
  'content.contract.C1-C.title': GameMessage(
    'Savunma sınavı',
    'Guard test',
    'Contract title.',
  ),
  'content.contract.C1-C.description': GameMessage(
    'En fazla 3 gard hamlesi kullan.',
    'Use no more than 3 Guard actions.',
    'Contract objective.',
  ),
  'content.contract.C1-D.title': GameMessage(
    'Fenerin gölgesi',
    'Shadow of the Lantern',
    'Contract title.',
  ),
  'content.contract.C1-D.description': GameMessage(
    'İşaretli alan turlarında hasar alma.',
    'Take no damage during marked-zone turns.',
    'Contract objective.',
  ),
  'content.contract.C2-A.title': GameMessage(
    'Kül kontrolü',
    'Ash control',
    'Contract title.',
  ),
  'content.contract.C2-A.description': GameMessage(
    'Kanama almadan kazan.',
    'Win without being afflicted with Bleed.',
    'Contract objective.',
  ),
  'content.contract.C2-B.title': GameMessage(
    'Zırh kırıcı',
    'Armor breaker',
    'Contract title.',
  ),
  'content.contract.C2-B.description': GameMessage(
    'Çelme veya büyü kullanarak kazan.',
    'Win using Sweep or a spell.',
    'Contract objective.',
  ),
  'content.contract.C2-C.title': GameMessage(
    'Isı yönetimi',
    'Heat management',
    'Contract title.',
  ),
  'content.contract.C2-C.description': GameMessage(
    'İşaretli buhar turunda hasar alma.',
    'Take no damage during a marked steam turn.',
    'Contract objective.',
  ),
  'content.contract.C2-D.title': GameMessage(
    'Matronun mühürleri',
    'The Matron’s seals',
    'Contract title.',
  ),
  'content.contract.C2-D.description': GameMessage(
    'Büyüyle durum etkisi uygula.',
    'Inflict a status effect with a spell.',
    'Contract objective.',
  ),
  'content.contract.C3-A.title': GameMessage(
    'Menzil hâkimiyeti',
    'Range mastery',
    'Contract title.',
  ),
  'content.contract.C3-A.description': GameMessage(
    'Menzil cezası almadan kazan.',
    'Win without suffering a range penalty.',
    'Contract objective.',
  ),
  'content.contract.C3-B.title': GameMessage(
    'Mühür bozma',
    'Break the seal',
    'Contract title.',
  ),
  'content.contract.C3-B.description': GameMessage(
    'İşaretli büyülere en az iki kez gard al.',
    'Guard against marked spells at least twice.',
    'Contract objective.',
  ),
  'content.contract.C3-C.title': GameMessage(
    'Kesintisiz tempo',
    'Unbroken tempo',
    'Contract title.',
  ),
  'content.contract.C3-C.description': GameMessage(
    '8 tur içinde kazan.',
    'Win within 8 turns.',
    'Contract objective.',
  ),
  'content.contract.C3-D.title': GameMessage(
    'Yargıcın açığı',
    'The Judge’s opening',
    'Contract title.',
  ),
  'content.contract.C3-D.description': GameMessage(
    'Menzil değiştirmeden kazan.',
    'Win without changing range.',
    'Contract objective.',
  ),
  'content.contract.C4-A.title': GameMessage(
    'Son hazırlık',
    'Final preparation',
    'Contract title.',
  ),
  'content.contract.C4-A.description': GameMessage(
    'Yarından fazla sağlıkla kazan.',
    'Win with more than half your health.',
    'Contract objective.',
  ),
  'content.contract.C4-B.title': GameMessage(
    'Komutanın açığı',
    'The Commander’s opening',
    'Contract title.',
  ),
  'content.contract.C4-B.description': GameMessage(
    'Her iki fazda da durum etkisi uygula.',
    'Inflict a status effect in both phases.',
    'Contract objective.',
  ),
  'content.contract.C4-C.title': GameMessage(
    'Şampiyon yemini',
    'Champion’s oath',
    'Contract title.',
  ),
  'content.contract.C4-C.description': GameMessage(
    'Seçili silah ailesiyle kazan.',
    'Win with the selected weapon family.',
    'Contract objective.',
  ),
  'content.contract.C4-D.title': GameMessage(
    'Mührü kır',
    'Shatter the seal',
    'Contract title.',
  ),
  'content.contract.C4-D.description': GameMessage(
    'İşaretli büyülere en az iki kez gard al.',
    'Guard against marked spells at least twice.',
    'Contract objective.',
  ),

  // Shop item names and effects, keyed by saved item IDs.
  'content.item.sword_1.name': GameMessage(
    'İskele Palası',
    'Pier Cutlass',
    'Shop item name.',
  ),
  'content.item.sword_1.description': GameMessage(
    'Yakında hızlı ve isabetli.',
    'Fast and accurate at close range.',
    'Shop item effect description.',
  ),
  'content.item.maul_1.name': GameMessage(
    'Rıhtım Tokmağı',
    'Quay Maul',
    'Shop item name.',
  ),
  'content.item.maul_1.description': GameMessage(
    'Yakın mesafede ek hasar.',
    'Deals extra damage at close range.',
    'Shop item effect description.',
  ),
  'content.item.spear_1.name': GameMessage(
    'Halat Mızrağı',
    'Rope Spear',
    'Shop item name.',
  ),
  'content.item.spear_1.description': GameMessage(
    'Uzakta isabet avantajı.',
    'Accuracy bonus at long range.',
    'Shop item effect description.',
  ),
  'content.item.bow_1.name': GameMessage(
    'Kıyı Yayı',
    'Coast Bow',
    'Shop item name.',
  ),
  'content.item.bow_1.description': GameMessage(
    'Maç başına 3 fişek.',
    '3 arrows per duel.',
    'Shop item effect description.',
  ),
  'content.item.helm_1.name': GameMessage(
    'Dalgakıran Başlığı',
    'Breakwater Cap',
    'Shop item name.',
  ),
  'content.item.helm_1.description': GameMessage(
    'Hafif baş koruması.',
    'Light head protection.',
    'Shop item effect description.',
  ),
  'content.item.coat_1.name': GameMessage(
    'Liman Yeleği',
    'Harbor Vest',
    'Shop item name.',
  ),
  'content.item.coat_1.description': GameMessage(
    'Güvenilir gövde zırhı.',
    'Reliable body armor.',
    'Shop item effect description.',
  ),
  'content.item.boots_1.name': GameMessage(
    'Halatçı Çizmeleri',
    'Rigger’s Boots',
    'Shop item name.',
  ),
  'content.item.boots_1.description': GameMessage(
    'Çevik adım.',
    'A nimble step.',
    'Shop item effect description.',
  ),
  'content.item.charm_1.name': GameMessage(
    'Tuzlu Cam Tılsım',
    'Saltglass Charm',
    'Shop item name.',
  ),
  'content.item.charm_1.description': GameMessage(
    'Büyü gücünü artırır.',
    'Increases spell power.',
    'Shop item effect description.',
  ),
  'content.item.sword_2.name': GameMessage(
    'Ayna Kılıç',
    'Mirrorblade',
    'Shop item name.',
  ),
  'content.item.sword_2.description': GameMessage(
    'İkinci devrenin dengeli kılıcı.',
    'A balanced sword for the second act.',
    'Shop item effect description.',
  ),
  'content.item.maul_2.name': GameMessage(
    'Örs Kıran',
    'Anvilbreaker',
    'Shop item name.',
  ),
  'content.item.maul_2.description': GameMessage(
    'Zırhlılara karşı ağır darbe.',
    'A heavy strike against armored foes.',
    'Shop item effect description.',
  ),
  'content.item.spear_2.name': GameMessage(
    'Ocak Mızrağı',
    'Forge Spear',
    'Shop item name.',
  ),
  'content.item.spear_2.description': GameMessage(
    'Mesafeyi elinde tut.',
    'Keep your opponent at range.',
    'Shop item effect description.',
  ),
  'content.item.bow_2.name': GameMessage(
    'Kor Yayı',
    'Ember Bow',
    'Shop item name.',
  ),
  'content.item.bow_2.description': GameMessage(
    'Maç başına 4 fişek.',
    '4 arrows per duel.',
    'Shop item effect description.',
  ),
  'content.item.helm_2.name': GameMessage(
    'Pirinç Alınlık',
    'Brass Browguard',
    'Shop item name.',
  ),
  'content.item.helm_2.description': GameMessage(
    'Ocak dövmesi pirinç.',
    'Brass forged in the foundry.',
    'Shop item effect description.',
  ),
  'content.item.coat_2.name': GameMessage(
    'Cüruf Zırhı',
    'Slag Armor',
    'Shop item name.',
  ),
  'content.item.coat_2.description': GameMessage(
    'Ağır ama dayanıklı.',
    'Heavy but durable.',
    'Shop item effect description.',
  ),
  'content.item.boots_2.name': GameMessage(
    'Kıvılcım Çizmeleri',
    'Spark Boots',
    'Shop item name.',
  ),
  'content.item.boots_2.description': GameMessage(
    'Çevikliği korur.',
    'Preserves agility.',
    'Shop item effect description.',
  ),
  'content.item.charm_2.name': GameMessage(
    'Kor Mührü',
    'Ember Seal',
    'Shop item name.',
  ),
  'content.item.charm_2.description': GameMessage(
    'Köz büyülerini güçlendirir.',
    'Empowers ember spells.',
    'Shop item effect description.',
  ),
  'content.item.sword_3.name': GameMessage(
    'Fırtına Dişi',
    'Stormfang',
    'Shop item name.',
  ),
  'content.item.sword_3.description': GameMessage(
    'Fırtınada dengeli kalır.',
    'Keeps its balance in the storm.',
    'Shop item effect description.',
  ),
  'content.item.maul_3.name': GameMessage(
    'Gelgit Ezici',
    'Tidecrusher',
    'Shop item name.',
  ),
  'content.item.maul_3.description': GameMessage(
    'Yüksek kuvvet, yüksek bedel.',
    'Great power comes at a cost.',
    'Shop item effect description.',
  ),
  'content.item.spear_3.name': GameMessage(
    'Gözlemci Mızrağı',
    'Observer Spear',
    'Shop item name.',
  ),
  'content.item.spear_3.description': GameMessage(
    'Uzak vuruşta üstün.',
    'Excels at long-range attacks.',
    'Shop item effect description.',
  ),
  'content.item.bow_3.name': GameMessage(
    'Şimşek Yayı',
    'Lightning Bow',
    'Shop item name.',
  ),
  'content.item.bow_3.description': GameMessage(
    'Maç başına 5 fişek.',
    '5 arrows per duel.',
    'Shop item effect description.',
  ),
  'content.item.helm_3.name': GameMessage(
    'Gözlemci Maskesi',
    'Observer Mask',
    'Shop item name.',
  ),
  'content.item.helm_3.description': GameMessage(
    'Fırtına görüşünü kesmez.',
    'Does not block your view in the storm.',
    'Shop item effect description.',
  ),
  'content.item.coat_3.name': GameMessage(
    'Gelgit Zırhı',
    'Tide Armor',
    'Shop item name.',
  ),
  'content.item.coat_3.description': GameMessage(
    'Dalga basıncına dayanır.',
    'Withstands the pressure of the waves.',
    'Shop item effect description.',
  ),
  'content.item.boots_3.name': GameMessage(
    'Amfitiyatro Çizmeleri',
    'Amphitheater Boots',
    'Shop item name.',
  ),
  'content.item.boots_3.description': GameMessage(
    'Kaygan zeminde denge.',
    'Keep your footing on slippery ground.',
    'Shop item effect description.',
  ),
  'content.item.charm_3.name': GameMessage(
    'Gelgit Gözü',
    'Eye of the Tide',
    'Shop item name.',
  ),
  'content.item.charm_3.description': GameMessage(
    'Büyü ve çeviklik.',
    'Magic and agility.',
    'Shop item effect description.',
  ),
  'content.item.sword_4.name': GameMessage(
    'Çember Kesiği',
    'Circlecutter',
    'Shop item name.',
  ),
  'content.item.sword_4.description': GameMessage(
    'Final devresinin hafif silahı.',
    'A light weapon for the final act.',
    'Shop item effect description.',
  ),
  'content.item.maul_4.name': GameMessage(
    'Taç Yıkan',
    'Crownbreaker',
    'Shop item name.',
  ),
  'content.item.maul_4.description': GameMessage(
    'Ağır savunmayı kırar.',
    'Breaks heavy defenses.',
    'Shop item effect description.',
  ),
  'content.item.spear_4.name': GameMessage(
    'Son Nöbet Mızrağı',
    'Last Watch Spear',
    'Shop item name.',
  ),
  'content.item.spear_4.description': GameMessage(
    'Final uzaklığında hâkimiyet.',
    'Controls the final range.',
    'Shop item effect description.',
  ),
  'content.item.bow_4.name': GameMessage(
    'Kül Şafağı Yayı',
    'Ash Dawn Bow',
    'Shop item name.',
  ),
  'content.item.bow_4.description': GameMessage(
    'Maç başına 6 fişek.',
    '6 arrows per duel.',
    'Shop item effect description.',
  ),
  'content.item.helm_4.name': GameMessage(
    'Taçsız Miğfer',
    'Crownless Helm',
    'Shop item name.',
  ),
  'content.item.helm_4.description': GameMessage(
    'Son savunma hattı.',
    'The final line of defense.',
    'Shop item effect description.',
  ),
  'content.item.coat_4.name': GameMessage(
    'Çember Zırhı',
    'Circle Armor',
    'Shop item name.',
  ),
  'content.item.coat_4.description': GameMessage(
    'Taç Halkası için dövüldü.',
    'Forged for the Crown Circle.',
    'Shop item effect description.',
  ),
  'content.item.boots_4.name': GameMessage(
    'Son Tur Çizmeleri',
    'Final Round Boots',
    'Shop item name.',
  ),
  'content.item.boots_4.description': GameMessage(
    'Son hamleye hareket bırakır.',
    'Save some movement for the final action.',
    'Shop item effect description.',
  ),
  'content.item.charm_4.name': GameMessage(
    'Çember Mührü',
    'Circle Seal',
    'Shop item name.',
  ),
  'content.item.charm_4.description': GameMessage(
    'Üç niteliğe güç verir.',
    'Boosts three attributes.',
    'Shop item effect description.',
  ),

  // Spell effect summaries and mastery text.
  'content.spell.emberSpear.description': GameMessage(
    '4 + 1.5×Büyü hasarı',
    '4 + 1.5×Arcana damage',
    'Spell effect summary; preserve the formula.',
  ),
  'content.spell.ashBurst.description': GameMessage(
    '10 + 1.5×Büyü hasarı ve yanma',
    '10 + 1.5×Arcana damage and Burn',
    'Spell effect summary; preserve the formula.',
  ),
  'content.spell.tideWard.description': GameMessage(
    '20 + 2×Büyü hasarı emen kalkan',
    'A shield that absorbs 20 + 2×Arcana damage',
    'Spell effect summary; preserve the formula.',
  ),
  'content.spell.saltCleanse.description': GameMessage(
    'Bir olumsuz etkiyi kaldır, sağlık yenile',
    'Remove one negative effect and restore health',
    'Spell effect summary.',
  ),
  'content.spell.swiftBreeze.description': GameMessage(
    'Sonraki hamleye +8 isabet',
    '+8 accuracy on your next action',
    'Spell effect summary.',
  ),
  'content.spell.shoreStep.description': GameMessage(
    'Mesafe değiştir, gelen saldırıyı zayıflat',
    'Change range and weaken the incoming attack',
    'Spell effect summary.',
  ),
  'content.mastery.front_1.name': GameMessage(
    'Sağlam duruş',
    'Firm Stance',
    'Mastery name.',
  ),
  'content.mastery.front_1.description': GameMessage(
    'Gardın hasar azaltımı +%5.',
    'Guard reduces damage by an additional 5%.',
    'Mastery effect description; preserve the 5% value.',
  ),
  'content.mastery.front_1.path': GameMessage(
    'Ön saflar',
    'Frontline',
    'Mastery tree path name.',
  ),
  'content.mastery.front_2.name': GameMessage(
    'Zırh kıran',
    'Armor Breaker',
    'Mastery name.',
  ),
  'content.mastery.front_2.description': GameMessage(
    'Güçlü vuruş zırhı +%10 daha çok yok sayar.',
    'Heavy Strike ignores 10% more armor.',
    'Mastery effect description; preserve the 10% value.',
  ),
  'content.mastery.front_2.path': GameMessage(
    'Ön saflar',
    'Frontline',
    'Mastery tree path name.',
  ),
  'content.mastery.front_3.name': GameMessage(
    'Karşılık',
    'Riposte',
    'Mastery name.',
  ),
  'content.mastery.front_3.description': GameMessage(
    'Gard sonrası +2 efor kazan.',
    'Gain +2 effort after guarding.',
    'Mastery effect description; preserve the +2 value.',
  ),
  'content.mastery.front_3.path': GameMessage(
    'Ön saflar',
    'Frontline',
    'Mastery tree path name.',
  ),
  'content.mastery.duel_1.name': GameMessage(
    'Keskin zamanlama',
    'Sharp Timing',
    'Mastery name.',
  ),
  'content.mastery.duel_1.description': GameMessage(
    'Hızlı vuruş isabeti +3 puan.',
    'Quick Strike gains +3 accuracy.',
    'Mastery effect description; preserve the +3 value.',
  ),
  'content.mastery.duel_1.path': GameMessage(
    'Düellocu',
    'Duelist',
    'Mastery tree path name.',
  ),
  'content.mastery.duel_2.name': GameMessage(
    'Ayak oyunu',
    'Footwork',
    'Mastery name.',
  ),
  'content.mastery.duel_2.description': GameMessage(
    'Mesafe değiştirince rakibin sonraki isabeti −10.',
    'After you change range, your rival’s next attack has −10 accuracy.',
    'Mastery effect description; preserve the −10 value.',
  ),
  'content.mastery.duel_2.path': GameMessage(
    'Düellocu',
    'Duelist',
    'Mastery tree path name.',
  ),
  'content.mastery.duel_3.name': GameMessage(
    'Açık bulma',
    'Find the Opening',
    'Mastery name.',
  ),
  'content.mastery.duel_3.description': GameMessage(
    'Niyete karşı gard sonrası hızlı vuruş kritik +5 puan.',
    'After guarding against an intent, Quick Strike gains +5 critical chance.',
    'Mastery effect description; preserve the +5 value.',
  ),
  'content.mastery.duel_3.path': GameMessage(
    'Düellocu',
    'Duelist',
    'Mastery tree path name.',
  ),
  'content.mastery.seal_1.name': GameMessage(
    'İlk mühür',
    'First Seal',
    'Mastery name.',
  ),
  'content.mastery.seal_1.description': GameMessage(
    'İlk büyü isabeti +5 puan.',
    'Your first spell gains +5 accuracy.',
    'Mastery effect description; preserve the +5 value.',
  ),
  'content.mastery.seal_1.path': GameMessage(
    'Mühürcü',
    'Binder',
    'Mastery tree path name.',
  ),
  'content.mastery.seal_2.name': GameMessage('Akış', 'Flow', 'Mastery name.'),
  'content.mastery.seal_2.description': GameMessage(
    'Her üçüncü tur mana yenilemesi +2.',
    'Restore +2 extra mana every third turn.',
    'Mastery effect description; preserve the +2 value.',
  ),
  'content.mastery.seal_2.path': GameMessage(
    'Mühürcü',
    'Binder',
    'Mastery tree path name.',
  ),
  'content.mastery.seal_3.name': GameMessage(
    'Köz artçısı',
    'Ember Wake',
    'Mastery name.',
  ),
  'content.mastery.seal_3.description': GameMessage(
    'Yanma hasarı +%1 maksimum sağlık.',
    'Burn damage also deals 1% of maximum health.',
    'Mastery effect description; preserve the 1% value.',
  ),
  'content.mastery.seal_3.path': GameMessage(
    'Mühürcü',
    'Binder',
    'Mastery tree path name.',
  ),
  'content.postgame.1.name': GameMessage(
    'Paslı Kanca · gard ve karşı hamle',
    'Rusty Hook · guard and counter',
    'Postgame trial subtitle.',
  ),
  'content.postgame.2.name': GameMessage(
    'Kızıl Ocak Şefi · buhar ipuçları',
    'Crimson Forge Chief · steam tells',
    'Postgame trial subtitle.',
  ),
  'content.postgame.3.name': GameMessage(
    'Fener Şampiyonu · iki faz',
    'Lantern Champion · two phases',
    'Postgame trial subtitle.',
  ),
  'content.postgame.4.name': GameMessage(
    'Pirinç Muhafız · zırh aşma',
    'Brass Guardian · armor piercing',
    'Postgame trial subtitle.',
  ),
  'content.postgame.5.name': GameMessage(
    'Kıyı Orakçısı · mana yönetimi',
    'Coast Reaper · mana management',
    'Postgame trial subtitle.',
  ),
  'content.postgame.6.name': GameMessage(
    'Gözlemci Başrahip · menzil ve faz',
    'Observer High Priest · range and phases',
    'Postgame trial subtitle.',
  ),
  'content.postgame.7.name': GameMessage(
    'Kül Komutanı · niyet dizisi',
    'Ash Commander · intent sequence',
    'Postgame trial subtitle.',
  ),
  'content.postgame.8.name': GameMessage(
    'Ayna Dövüşçü · kendi yapınla yüzleş',
    'Mirror Fighter · face your own build',
    'Final postgame trial that mirrors the player build.',
  ),
  'ui.encounter.level': GameMessage(
    'Seviye {level}',
    'Level {level}',
    'Encounter level in a list card.',
  ),
  'ui.encounter.shortChampion': GameMessage(
    'ŞAMPİYON',
    'CHAMPION',
    'Compact encounter type label.',
  ),
  'ui.encounter.shortIntermediateFinal': GameMessage(
    'DEVRE FİNALİ',
    'ACT FINAL',
    'Compact encounter type label for an intermediate tournament final.',
  ),
  'ui.encounter.shortElite': GameMessage(
    'ELİT',
    'ELITE',
    'Compact encounter type label.',
  ),
  'ui.encounter.shortDuel': GameMessage(
    'DÜELLO',
    'DUEL',
    'Compact encounter type label.',
  ),
  'ui.fighter.redistribution': GameMessage(
    'Ücretsiz yeniden dağıtım · {count} hak',
    'Free respec · {count} uses',
    'Free attribute redistribution count.',
  ),
  'ui.encounter.masterySuffix': GameMessage(
    'Ustalık Sınaması',
    'Mastery Trial',
    'Suffix appended to the rival name for a Champions’ Road encounter.',
  ),
};

class GameLocalizations {
  const GameLocalizations(this.languageCode);

  final String languageCode;

  bool get isEnglish => languageCode == 'en';

  static GameLocalizations of(BuildContext context) {
    final scoped = GameLocaleScope.maybeOf(context)?.languageCode;
    if (scoped != null) {
      return GameLocalizations(scoped == 'en' ? 'en' : 'tr');
    }
    final locale = Localizations.maybeLocaleOf(context);
    return GameLocalizations(
      locale?.languageCode == 'en' && locale?.countryCode == null ? 'en' : 'tr',
    );
  }

  String text(String key, [Map<String, Object?> arguments = const {}]) {
    final message = gameMessages[key];
    if (message == null) return key;
    final source = isEnglish ? message.english : message.turkish;
    return _formatMessage(source, arguments, languageCode);
  }

  String uppercase(String value) => isEnglish
      ? value.toUpperCase()
      : value.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
}

String gameText(
  BuildContext context,
  String key, [
  Map<String, Object?> arguments = const {},
]) => GameLocalizations.of(context).text(key, arguments);

String localizedContent(
  BuildContext context,
  String group,
  String id,
  String field,
) => gameText(context, 'content.$group.$id.$field');

String localizedHeading(BuildContext context, String key) =>
    GameLocalizations.of(context).uppercase(gameText(context, key));

String _formatMessage(
  String message,
  Map<String, Object?> arguments,
  String languageCode,
) {
  final output = StringBuffer();
  var index = 0;
  while (index < message.length) {
    if (message[index] != '{') {
      output.write(message[index]);
      index++;
      continue;
    }
    final close = _matchingBrace(message, index);
    if (close == -1) {
      output.write(message.substring(index));
      break;
    }
    final expression = message.substring(index + 1, close);
    final plural = _formatPlural(expression, arguments, languageCode);
    if (plural != null) {
      output.write(plural);
    } else {
      final name = expression.trim();
      final value = arguments[name];
      output.write(value ?? '{$name}');
    }
    index = close + 1;
  }
  return output.toString();
}

String? _formatPlural(
  String expression,
  Map<String, Object?> arguments,
  String languageCode,
) {
  final marker = expression.indexOf(', plural,');
  if (marker < 0) return null;
  final name = expression.substring(0, marker).trim();
  final value = arguments[name];
  final count = value is num ? value : num.tryParse('$value');
  if (count == null) return null;
  final options = _pluralOptions(expression.substring(marker + 9));
  final exact = options['=${count.toString()}'];
  // The app currently ships only Turkish and English. Both CLDR cardinal
  // systems use the `one` and `other` categories for the integer counts shown.
  final category = count == 1 ? 'one' : 'other';
  final selected = exact ?? options[category] ?? options['other'] ?? '';
  return _formatMessage(
    selected.replaceAll('#', count.toString()),
    arguments,
    languageCode,
  );
}

Map<String, String> _pluralOptions(String source) {
  final options = <String, String>{};
  var index = 0;
  while (index < source.length) {
    while (index < source.length && source[index].trim().isEmpty) {
      index++;
    }
    final keyStart = index;
    while (index < source.length && source[index] != '{') {
      index++;
    }
    if (index >= source.length) break;
    final key = source.substring(keyStart, index).trim();
    final close = _matchingBrace(source, index);
    if (close == -1) break;
    options[key] = source.substring(index + 1, close);
    index = close + 1;
  }
  return options;
}

int _matchingBrace(String value, int open) {
  var depth = 0;
  for (var index = open; index < value.length; index++) {
    if (value[index] == '{') depth++;
    if (value[index] == '}' && --depth == 0) return index;
  }
  return -1;
}
