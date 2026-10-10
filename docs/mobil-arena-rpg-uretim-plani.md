# Mobil Arena RPG — Oyun ve Üretim Planı

**Belge türü:** Ürün tanımı, oyun tasarım belgesi ve üretim yol haritası  
**Sürüm:** 1.30
**Tarih:** 10 Ekim 2026  
**Durum:** Tam oyun üretim planı; Flutter uygulaması geniş kapsamlı oynanabilir içerik içeriyor ve yayın kapılarını kapatma çalışması sürüyor  
**Çalışma adı:** Kül Çemberi  
**Hedef:** Flutter ile Android ve iOS için çevrimdışı, tek oyunculu, portre yönelimli arena RPG

> Bu belge, Swords and Sandals 2’nin yüksek seviyeli arena-RPG döngüsünden esinlenen, kendi adı, dünyası, karakterleri, kuralları ve görsel dili olan yeni bir oyun için hazırlanmıştır. Aşağıdaki sayısal değerler ve içerik önerileri bu yeni oyun için başlangıç tasarımıdır; referans oyunun doğrulanmış formülleri veya bire bir içerik listesi değildir.

## 1. Kapsam ve referans sınırı

CrazyGames açıklaması referans için şu özellikleri doğruluyor: gladyatör karakter yaratma ve görünüş düzenleme, Strength/Stamina benzeri özelliklere puan verme, seçilebilir sıra tabanlı hamleler, bazı hamlelerde başarı olasılığı gösterimi, maç sonrası altın ve seviye/özellik puanı kazanımı, kasaba dükkânlarından silah, zırh ve büyü alma. Sayfa verilen sürümü Ruffle motorlu, masaüstü tarayıcı ve fare kontrollü olarak listeliyor; tamamlama süresini 9–10 saat olarak tahmin ediyor. [CrazyGames referans sayfası](https://www.crazygames.com/game/swords-and-sandals-2)

### 1.1 Kaynak oyunu, sürüm ayrımı ve kaynak güveni

CrazyGames sayfası Fandom bağlantısı veriyor ve barındırdığı tarayıcı sürümünü Ruffle üzerinde, masaüstü tarayıcıda oynanır olarak tanımlıyor. Bu sayfa erişilebilen bir tarayıcı referansıdır; tek başına bu build’in indirilebilir özgün Flash build’iyle, Steam Classic Collection’la veya Redux içindeki “Classic Edition” seçeneğiyle aynı olduğunu kanıtlamaz. Plan her kaynak iddiasını ait olduğu sürümle etiketler ve build’ler arasında eşdeğerlik varsaymaz. CrazyGames’in 9–10 saatlik bitirme süresi bir sayfa tahminidir; doğrulanmış süre ölçümü veya bu oyunun hedefi değildir. [CrazyGames — Swords and Sandals 2](https://www.crazygames.com/game/swords-and-sandals-2)

Fandom ve Flash Gaming Wiki topluluk kaynaklarıdır; mekanik ayrıntıları keşfetmek ve oynanabilir sürümde kontrol edilecek soruları çıkarmak için kullanılır. Kaynak önceliği sürüm ve katalog iddialarında geliştirici/resmî platform açıklamaları, mekaniklerde açıkça seçilip sabitlenmiş oynanabilir build, ardından wiki keşif kayıtlarıdır. CrazyGames’in 10 Ekim 2026’da görülen “Wiki pages” bağlantısı Fandom’a gider; geliştiricinin resmi Tome of Lore önsözü de eski `swordsandsandals.wikia.com` alanındaki hayran wikisini anıp lore bilgisinin aktarılmasına izin verir. Bu bağlantılar topluluk kaynağının varlığını doğrular, Fandom’daki her mekanik iddiasını veya sürüm eşleşmesini onaylamaz. 10 Ekim 2026 tarihli bu ek araştırmada Fandom alt sayfaları robots.txt/restricted URL yanıtıyla doğrudan açılamadı; arama sonuçları yaklaşık üç ay önce taranmış sayfalardan boss sırası, karakter profili, silah ve zırh tabloları ile oyun hatası kayıtları sundu. Flash Gaming Wiki’nin S&S 2 sayfası arama dizininde daha geniş metin olarak erişilebildi. Bu sonuçlar canlı Classic build’i veya wiki değişiklik geçmişini doğrulamaz. Topluluk sayfaları Classic, Redux ve başka seri oyunlarını bir arada anlatabiliyor; profil ve tablo kayıtlarının bir kısmı eksik veya taslak. Kesin istatistik, fiyat, seviye eşiği, formül ve hata raporları bu nedenle düşük güvenli iddialardır; oynanabilir ve sürümü sabitlenmiş build’de doğrulanmadan ürün gereksinimi sayılmaz. [CrazyGames’teki Fandom bağlantısı](https://www.crazygames.com/game/swords-and-sandals-2), [Wiki’nin kaynak/katkı açıklaması](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_Wiki)

| Kaynak / sürüm | Kaynakta yer alan / keşfedilen bilgi | Bu üretim planındaki karşılığı ve sınırı |
|---|---|---|
| CrazyGames — Ruffle tarayıcı sürümü | Sayfa; karakter görünüşü/özellik puanları, sıra tabanlı seçilebilir hamleler ve bazı hamlelerde başarı olasılığı, maç sonrası altın ve seviye/özellik puanı, kasabada silah-zırh-büyü alışverişi anlatır. Sayfa Ruffle, masaüstü tarayıcı ve fare kontrolü bildirir. | Yeni oyunun genel karakter kurma → taktik dövüş → ödül/ilerleme → ekipman alışverişi döngüsü için karşılaştırma kaynağıdır. Formüller, belirli içerik sayıları ve 9–10 saat tahmini yeni oyun gereksinimi değildir. |
| Newgrounds — yapımcının tanıtım build’i | Yazar notu turnuvalar, menzilli silahlar, büyüler ve şampiyonları sayar; sayfanın sürümü tanıtım build’idir. Notta tam sürümde 10 gladyatöre kadar kayıt ve v1.03’te ilk üç turnuvayı bitirme bilgisi yer alır. | Dönemin mekanik aileleri için yapımcı kaynaklı ipucudur. İlk üç turnuva ifadesi tanıtım sürümüne aittir; tam oyunun turnuva sayısı olarak kullanılmaz. |
| Fandom — özellik ve görev sayfaları | Classic karakter profilleri Strength, Agility, Attack, Defence, Vitality, Charisma, Stamina ve Magicka’yı ayrı alanlar olarak listeler. Görev maddelerinde maç arası seçimlerin özellik veya kaynakları değiştirebildiği örnekler bulunur. Charisma’nın seyirci, taunt, ödül ve mağaza indirimiyle aynı anda ilişkilendirildiği yazılır. | İsabeti çeviklikten ayıran yedinci özellik **İsabet** eklenir; Charisma’nın çoklu ekonomi etkisi ayrı bir harcanabilir özelliğe dönüştürülmez. Dört tek-seferlik ara-turnuva kararı tasarlanır; seçenek ve etkisi önceden görünür, altın/özellik sonuçları ekonomi simülasyonuna katılır. Bunlar wiki’deki aynı görevlerin veya ödüllerin kopyası değildir. [Wiki — Emperor’s Reign](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_2%3A_Emperor%27s_Reign), [Wiki — Quests](https://swordsandsandals.fandom.com/wiki/Quests), [Wiki — Charisma](https://swords-and-sandals.fandom.com/wiki/Charisma) |
| Flash Gaming Wiki — başlangıç, dükkân ve turnuva akışı | Oyuncunun görünüş/özellik seçimi sonrası zindandaki zayıf bir rakiple ilk düelloya girdiğini, galibiyetle kasabaya çıktığını; silahçı, zırhçı, büyü dükkânı ve kilise hizmetlerini; yüksek seviyelerde daha zor ve daha çok altın veren turnuvaların açıldığını anlatır. Kilise açıklamasında sağlık ve kondisyon iksirleri vardır. | Açılış akışı tek öğretici maçta tamamlanır; lig merkezi sonrasında dört dükkân işlevini ayrı, anlaşılır mobil sekmeler olarak sunar. Ana rota karşılaşmaları kampanya bayraklarıyla açılır; önerilen seviye gösterilir, seviye tek başına ilerlemeyi kilitlemez. İksirlerin taktik hazırlıkta yeri vardır ama sarf olmadan kampanya tamamlanabilir. Kaynakta bu akışın build/sürüm doğrulaması yoktur. [Flash Gaming Wiki — Swords and Sandals 2](https://flashgaming.fandom.com/wiki/Swords_And_Sandals_2) |
| Fandom ve Flash Gaming Wiki — topluluk rehberleri | Fandom’daki Emperor’s Reign rehberi kasaba/dükkân ayrımı, yakın dövüş ve menzilli silahlar, mühimmat, Charisma ve zırh parçası etkileri hakkında daha ayrıntılı iddialar listeler. Flash Gaming Wiki 77 silah sayar (21 slashing, 20 hacking, 19 bashing, 17 ranged); bu sayımın tablo/sürüm kapsamı belirsizdir. | Keşif ve doğrulama kontrol listesi olarak kullanılır. Ayrıntılar Classic oynanışında doğrulanmadan gereksinim sayılmaz; 77, aile veya kademe sayısı yeni oyunun içerik kotasını belirlemez. |
| Fandom — silah, yuva ve mühimmat tabloları | Silah rehberi her silah için Strength/Agility koşulu ve fiyat bulunduğunu; kılıç tablosunda 3–60 Agility ile 1.285–94.538 altın arasında bir ilerleme gösterir. Balta/topuz bilgisi boş, yay tablosu kısmi ve bazı enchant değerleri tutarsızdır. Ana oyun sayfası yakın/menzilli yuvaları, 5’ten başlayıp 10/15/20/25/30’a çıktığını iddia ettiği fişek kapasitesini ve dört enchant türünü listeler. Bunlar bağımsız oyun içi doğrulama değildir. | Katalogda seviye ve özellik koşulları ayrı alanlar olur; ikisi, etkisi ve fiyatı satın almadan önce görünür. Yeni oyunun 20 seviye ve dört devre eğrisine göre şartlar/fiyatlar sıkıştırılır. Yay fişeği 3/4/5/6 olarak devre başına yenilenir; Classic’in 9/23/28/35/45. seviye eşikleri kopyalanmaz. Rastgele silah enchantment’ı ilk yayın kapsamına girmez; element etkileri açık maliyetli büyü ve tılsım kartlarında gösterilir. [Wiki — S&S II Weapons](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_II_Weapons), [Wiki — Emperor’s Reign](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_2%3A_Emperor%27s_Reign) |
| Fandom — Classic şampiyon sırası ve rakip profilleri | Arena Bosses arama dizini 18 numaralı Classic boss kaydı gösterir: #1 John, #2 Evil Ninja, #3 Son of Stylonius, #4 Marksman Dantus, #5 Great Beast, #6 Wizard Sagan, #7 Slave Driver, #8 Spheracles, #9 Maharaja Saeed, #10 Gaiax, #11 Daimyo Katsumodo, #12 HeChaos, #13 Zeerzabahl, #14 Sir Belgrave, #15 Bargle Yarg, #16 Sandalphon, #17 oyuncu aynası ve #18 Antares. Başka sayfalarda Bhaargle/Bargle Yarg yazımı değişir; bireysel profiller Classic ve Redux sıra numaralarını ayrı verir (ör. Gaiax #10/#9, Nameless Shadow #17/#19), bazıları ilerleme/oyun modu ayrımı da bildirir. | Bu, oynanışta teyit edilmiş roster değil, toplulukta indekslenen 18 maddelik sıra iddiasıdır. Resmî Tome “20 notable Arena Champions” ifadesini kullanır; fakat bu ifadenin altındaki görünen bölüm 22 ayrı karakter maddesi sıralar ve Sir Belgrave’in Classic’te dövüşülen, Redux’ta NPC olan bir karakter olduğunu ayrıca açıklar. Dolayısıyla 18, 20 ve 22 farklı kapsam/sayım iddialarıdır; hiçbiri tek başına Classic build’in dövüş sırasını doğrulamaz. Yeni oyunun 32 maçı ve 8 finali bağımsız kapsamdır; yalnızca menzil, büyü, ağır saldırı, dayanıklılık, karma yapı ve ayna karşılaşması gibi rol çeşitliliği sinyalleri alınır. [Wiki — Arena Bosses](https://swordsandsandals.fandom.com/wiki/Arena_Bosses), [Wiki — Nameless Shadow](https://swordsandsandals.fandom.com/wiki/The_Nameless_Shadow), [Resmi Tome of Lore — S&S II](https://swordsandsandals.com/), [Resmi Classic Collection tanıtımı](https://swordsandsandals.com/swords-and-sandals-classic-collection/), [Bhaargle profile](https://swordsandsandals.fandom.com/wiki/Bhaargle), [Wiki — The Great Beast](https://swordsandsandals.fandom.com/wiki/The_Great_Beast), [Wizard Sagan](https://swordsandsandals.fandom.com/wiki/Wizard_Sagan), [The Slave Driver](https://swordsandsandals.fandom.com/wiki/The_Slave_Driver), [Spheracles](https://swordsandsandals.fandom.com/wiki/Spheracles), [Gaiax](https://swordsandsandals.fandom.com/wiki/Gaiax), [Daimyo Katsumodo](https://swordsandsandals.fandom.com/wiki/Daimyo_Katsumodo), [Zeerzabahl](https://swordsandsandals.fandom.com/wiki/Archfiend_Zeerzabahl), [Sandalphon](https://swordsandsandals.fandom.com/wiki/Archangel_Sandalphon), [Antares](https://swordsandsandals.fandom.com/wiki/Emperor_Antares) |
| Fandom ve Flash Gaming Wiki — zırh yuvası sayımı | İndekslenen tablolar yedi giyilebilir zırh parçası ile ayrı kalkanı gösteriyor; Flash Gaming Wiki ayrıca 23 kalkan kaydı veriyor. “Sekiz” sayımı, kalkanın sekizinci savunma ekipmanı konumu olarak eklenmesiyle açıklanabiliyor; bu muhtemel bir uzlaştırmadır, oynanabilir build’de doğrulanmış ortak terminoloji değildir. Flash rehberi kalkanların menzilli saldırıları bloklamaya yaradığını söyler. | Mobil sürüm UX ve yükleme sadeliği kararı olarak üç işlevsel zırh yuvasında kalır: başlık kritik/durum direnci, gövde temel hasar azaltımı, çizme konum/kaçınma desteği. Her parça bir ana pasif taşır; simgesi ve sayısal etkisi kartta görünür. Ayrı kalkan envanter yuvası eklenmez; her oyuncunun erişebildiği **Gard** hamlesi menzilli saldırılar dâhil gelen hasarı azaltır. Bu, referans sayımını çözme iddiası değil, mobil savaşta savunma karşı oyunu sağlamaya yönelik ürün kararıdır. [Wiki — Emperor’s Reign](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_2%3A_Emperor%27s_Reign), [Flash Gaming Wiki — S&S 2](https://flashgaming.fandom.com/wiki/Swords_And_Sandals_2) |
| Flash Gaming Wiki — zırh/karakter görünüşü | İndekslenen rehber yedi giyilebilir zırh parçasını, ayrıca 23 kalkan kaydını ve miğfer fiyat örneklerini gösterir: Peasant 1.200; 6. seviyede Militia/Veteran 7.500/10.800; 12. seviyede Hoplite/Swashbuckler/Retarius 14.700/19.200/24.300; 48. seviyede Champion 187.500 altın. Aynı sayfa karakter yaratmada ırk, saç ve yüz kılı seçeneklerinden söz eder. Katalog tamlığı ve build eşleşmesi doğrulanmamıştır. | Mobilde üç işlevsel zırh yuvası dört devre kademesinde gerçek savaş rolü taşır. Seçim derinliği modüler baş/saç, yüz kılı, ten ve gövde kozmetiğiyle sağlanır; zırh seviyesi karakter silüetinde ve dükkân kartında görünür. Uzun seviye/fiyat kuyruğu Classic build’de doğrulanmadan yeni kampanyaya taşınmaz; yuva, kalkan veya miğfer sayıları içerik kotası değildir. [Flash Gaming Wiki — Swords and Sandals 2](https://flashgaming.fandom.com/wiki/Swords_And_Sandals_2) |
| Fandom — bilinen hatalar sayfası | Topluluk listesi sürüme bağlı kayıt kaybı, alışveriş sonrası bakiyenin yenilenmesi, bazı mesafelerde hamle/weapon switch kilidi, arena sınırı sorunları, aşırı menzilli hasar, değiştirilen enchant’ın eski türde tetiklenmesi ve şart dışı rakip ekipmanı örnekleri verir. Sayfa bu sorunların tek bir build’de bulunmadığını özellikle belirtir. | QA kapıları atomik alışveriş/kayıt, her mesafede yasal hamle, arena konum sınırı, menzilli hasar tavanı, koşul doğrulamalı rakip donanımı, eşya değişim geçişi ve yeniden açılış tutarlılığını kapsar. Bu hata örnekleri yeni oyunda varmış gibi varsayılmaz. [Wiki — S&S II Bugs](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_II_Bugs) |
| Resmi Tome of Lore — S&S II | Yapımcının lore kaynağı Doomtrek’te altı yeni arena der ve “20 notable Arena Champions” ifadesini kullanır. Aynı bölümdeki görünür listede 22 karakter maddesi vardır. Bu listede Fearful Prisoner’ın S&S II açılışındaki tutorial rakibi olup sonradan S&S III şampiyonu olduğu, Bhaargle’ın ise kendisini şampiyon gibi tanıtıp maçı bilerek kaybettiği anlatılır; bu iki istisnayı çıkarmak 20’yi verir, fakat bu çıkarım yazarın açıkça tanımladığı sayım yöntemi değildir. Kaynak ayrıca Sir Belgrave’in Classic’te dövüşülen, Redux’ta NPC olan karakter olduğunu açıklar. | Sürüm ve anlatı kapsamı için birincil kaynaktır, oyun veritabanı veya maç sıra tablosu değildir. Fandom’ın 18 sıralı boss iddiasıyla aynı şeyi saydığı varsayılmaz; kesin Classic rosterı seçilen build’de oynanarak doğrulanmalıdır. Yeni oyunda 6 arena, sayı paritesi için değil, bölüm bölüm ayrışan görsel ve mekanik mekân kimlikleri için bağımsız ürün kararıdır. [Resmi Tome of Lore — S&S II](https://swordsandsandals.com/) |
| Steam ve Google Play — S&S 2 Redux | Redux listeleri yeniden düzenlenmiş grafik/müzik, 30’dan fazla savaş yeteneği, 200’den fazla silah/zırh parçası, 20 arena şampiyonu ve altı arena sayar. Google Play listesi ilk üç turnuvayı ücretsiz, 4–20 aralığını tek seferlik satın alımla açılır olarak tanımlar. Steam’deki “Classic Edition” ayarı Redux uygulaması içindeki sürüm seçeneğidir; geliştirici duyurusu bu modda görsel/dükkân geri dönüşlerinin yanında turnuva ve denge değişiklikleri bulunduğunu bildirir. | Redux sayıları ve kilit akışı yalnızca Redux sürümüne aittir; ayardaki Classic Edition özgün Flash build’iyle eşdeğer kabul edilmez. [Steam — Redux](https://store.steampowered.com/app/649600/Swords_and_Sandals_2_Redux/), [Google Play — Redux](https://play.google.com/store/apps/details?id=air.com.game.whiskeybarrelstudios.swordsandsandals2), [Geliştirici — Redux Classic Edition duyurusu](https://store.steampowered.com/news/app/649600/view/4738306083312209369) |
| Steam — Swords and Sandals Classic Collection | Mağaza tanıtımı “yirmi efsanevi dövüşçü” ifadesini kullanır; kesin S&S II rosterı veya maç sırası vermez. | Seri koleksiyonu pazarlama ifadesi, Classic S&S II karşılaşma tablosu olarak kullanılmaz. [Steam — Classic Collection](https://store.steampowered.com/app/1055430/Swords_and_Sandals_Classic_Collection/) |

### 1.2 Wiki bulgularının üretim kararlarına dönüşümü

| Kaynak sinyali | Kül Çemberi için uygulama |
|---|---|
| Fandom [Items](https://swordsandsandals.fandom.com/wiki/Items) özeti savaşta kullanılabilecek iksir ve büyüleri Magicka düzeyine bağlıyor; ifade bunun satın alma, öğrenme, kuşanma veya taşıma kapasitesi koşullarından hangisi olduğunu açıklamıyor. | Büyü kartları için `minLevel`/`minAttribute` koşulları açık veri alanı olur; dükkân, hazırlık ekranı ve savaş girişi aynı uygunluk kuralını kullanır ve gereken Büyü/seviye önceden görünür. Büyü özelliği sarf yuvası veya sarf adedini gizlice değiştirmez; maç başına bir sarf sınırı korunur. Wiki’deki belirsiz koşul bire bir kopyalanmadan görünür ilerleme kuralına çevrilir. |
| Fandom [Emperor’s Reign](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_2%3A_Emperor%27s_Reign) arama özeti, bazı çevrimiçi sürümlerde yay/arıbalet takılıyken Whirlwind büyüsünün mesafeden bağımsız isabet edebildiğini ve zırhı tamamen bitmişken zırh yenileme iksirinin bazı sürümlerde etkisiz kaldığını bildiriyor. Bu sayfalar bu araştırmada doğrudan açılamadı; kayıtlar sürüme bağlı ve doğrulanmamış topluluk iddialarıdır. | Bildirilen davranışlar oyuna alınmaz. QA; her büyünün üç mesafe bandında ve her silah ailesi takılıyken tanımlı hedefleme kuralını korumasını, sarfların sıfır kaynak/tam kaynak/sınır değerlerinde doğru çalışmasını doğrular. Geçersiz veya etkisiz kullanım eşya/kaynak tüketmez; geçerli kullanım etkisi, kaynak düşümü ve kayıt tek işlemde sonuçlanır. |
| Flash Gaming Wiki dört ayrı hizmet tanımlar: silahçı, zırhçı, büyü dükkânı ve kilise; kilise sağlık/kondisyon iksirleri satar. Altın galibiyetlerden gelir; daha ileri turnuvalarda zorluk ve ödül artar. | Lig merkezinde hizmetler dört mobil kategori/sekme olarak sunulur: silah, zırh, büyü-tılsım, sarf. Ayrı NPC gezintisi zorunlu değildir. Ana rota düğümleri önceki karşılaşma tamamlandığında açılır; önerilen seviye gösterilir ama seviye tek başına kampanyayı kilitlemez. Sarflar hazırlık seçeneğidir, tamamlanma şartı değildir. [Flash Gaming Wiki — S&S 2](https://flashgaming.fandom.com/wiki/Swords_And_Sandals_2) |
| Flash Gaming Wiki yedi giyilebilir zırh parçası ve miğfer fiyat örnekleri verir. Aynı sayfa karakter yaratmada görünüş, saç ve yüz kılı seçeneklerini belirtir. Bu topluluk kaydı Classic build’de doğrulanmamıştır. | Üç işlevsel zırh yuvası ve dört devre kademesi korunur; bu sayı mobil donanım/denge kararıdır. Çeşitlilik her yuvanın açık taktik rolü, dövüşçü silüetindeki görünür kademe farkı ve modüler baş/saç/yüz kılı/ten/gövde kozmetiğiyle sağlanır. Referansın slot veya katalog sayısı kopyalanmaz; yüz kılı seçenekleri karakter oluşturma kapsamına eklenir. [Flash Gaming Wiki — S&S 2](https://flashgaming.fandom.com/wiki/Swords_And_Sandals_2) |
| Flash Gaming Wiki kalkanları ayrı bir ekipman türü sayar; rehberde 23 kalkan kaydı vardır ve menzilli saldırılara karşı bloklama işlevi belirtilir. | Savunma karşı oyunu ekipman satın almaya bağlı olmaz: tüm yapılarda **Gard** menzilli saldırı hasarını da %45 azaltır. Ayrı kalkan katalog/yuvası bu yayında yoktur; bu seçim ek mağaza/animasyon yükü ve mobil yükleme karmaşıklığını sınırlayan ürün kararıdır. [Flash Gaming Wiki — S&S 2](https://flashgaming.fandom.com/wiki/Swords_And_Sandals_2) |
| Wiki’nin Classic boss listesi 18 şampiyonu sıralar. Dantus menzili, Sagan büyüyü, Spheracles ağır vuruşu, Gaiax dayanıklılık/çeviklik karşıtlığını, Sandalphon çok yönlü yüklemeyi, Nameless Shadow ayna eşleşmesini ve Antares son zirveyi temsil eder. Aynı maddeler Classic ile Redux sırasını ayırır; bazı karakter sayfaları taslak ve birkaç ekipman/stat satırı kendi içinde sorunludur. Resmi Tome “20 notable” der; görünen 22 maddenin tutorial rakibi ve bilerek kaybeden Bhaargle maddelerini hariç tutup 20’ye ulaşmak olası sayım açıklamasıdır, ancak bu yalnızca araştırmacı çıkarımıdır. | 32 maç 4 bölüm ve 8 dört maçlık turnuvaya ayrılır; her dört maçlık blok bir finalle biter, her sekizinci maç bölüm şampiyonudur. Böylece bölümün yeni rolü tanıtılır, ilk turnuva finalinde erken sınanır ve ikinci turnuva finalinde birleştirilir. Kampanya 8 farklı final rakibi/karşılaşma kartı içerir; 4’ü bölüm şampiyonu, 4’ü ara turnuva finalidir. Kaynaklardan 18, 20 veya 22 rakip kotası alınmaz; yalnızca rol çeşitliliği ve sınanabilir karşı oyunlar alınır. [Wiki — Arena Bosses](https://swordsandsandals.fandom.com/wiki/Arena_Bosses), [Wiki — Marksman Dantus](https://swordsandsandals.fandom.com/wiki/Marksman_Dantus), [Wiki — Wizard Sagan](https://swordsandsandals.fandom.com/wiki/Wizard_Sagan), [Wiki — Spheracles](https://swordsandsandals.fandom.com/wiki/Spheracles), [Wiki — Gaiax](https://swordsandsandals.fandom.com/wiki/Gaiax), [Wiki — Sandalphon](https://swordsandsandals.fandom.com/wiki/Archangel_Sandalphon), [Wiki — Nameless Shadow](https://swordsandsandals.fandom.com/wiki/The_Nameless_Shadow), [Wiki — Antares](https://swordsandsandals.fandom.com/wiki/Emperor_Antares), [resmi Tome of Lore](https://swordsandsandals.com/) |
| Wiki stat sayfaları sekiz ayrı özelliği (Strength, Agility, Attack, Defence, Vitality, Charisma, Stamina, Magicka) listeler. Görev kayıtlarında düello dışı seçimlerin stat veya kaynağı değiştirdiği örnekler vardır. | Yeni sistem yedi savaş özelliğini ayırır: Kuvvet, Çeviklik, İsabet, Dayanıklılık, Savunma, Kondisyon, Büyü. Ayrı Attack/Agility alanları mobil yapı çeşitliliği için korunur. Charisma’nın fiyat, ödül, seyirci ve taunt’a aynı anda bağlanmasının snowball riski nedeniyle Seyirci Notu harcanabilir puan vermez. Her ara turnuva sonrası tek seferlik altın veya özellik puanı seçimi bulunur; sonuç önceden gösterilir, kaydedilir ve yeniden oynanarak çiftlenemez. [Wiki — Emperor’s Reign](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_2%3A_Emperor%27s_Reign), [Wiki — Quests](https://swordsandsandals.fandom.com/wiki/Quests), [Wiki — Charisma](https://swords-and-sandals.fandom.com/wiki/Charisma) |
| Topluluk rehberi ilerleyen turnuvalarda daha güçlü rakip ve daha yüksek ödül iddia eder. Kılıç örnekleri 1.285–94.538 altına, bazı enchant örnekleri milyonlara çıkar; aynı sayfada eksik ve tutarsız tablo hücreleri vardır. Karizma sayfası tribün, taunt ve tüccar fiyatlarını tek özelliğe bağlar. | Sikke ödülü ve sıradaki hedef sonuç kartında görünür; tekrar galibiyeti ödül çiftçiliği yapmaz. Dört devreli, 20 seviye yeni eğride fiyatlar normalleştirilir; her devrede yaklaşık iki anlamlı yükseltme finanse edilir. Karizma benzeri harcanabilir ekonomi statı eklenmez; **Seyirci Notu** yalnızca skor/arma verir. Classic altın fiyatları kopyalanmaz. [Wiki — S&S II Weapons](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_II_Weapons), [Wiki — Charisma](https://swords-and-sandals.fandom.com/wiki/Charisma) |
| Wiki ayrı yakın dövüş/menzilli silah yuvaları, özellik koşulları ve seviyeye bağlı fişek kapasitesi tarif eder; zırh tabloları yedi giyilebilir parçayı ve ayrı kalkanı listeler. Tabloların eksik olması ve seviye 20’yi aşan eşikler nedeniyle bunlar doğrudan mobil gereksinim değildir. | Yakın dövüş + isteğe bağlı yay yuvası ve 3/4/5/6 fişek devre kapasitesi korunur. Üç zırh yuvası mobil ekranda kalır; bu seçim kullanıcı arayüzü ve denge kapsamıdır, kaynak sayımını çözme iddiası taşımaz. Her yuva ayrı taktik rolü taşır. Katalog kartı `minLevel`, `minAttribute`, fiyat, stat farkı, taktik rol ve görsel anahtar gösterir; karşılanmayan şart satın alım/kuşanım öncesinde açıklanır. |
| Resmi Tome of Lore — anlatı ve arena ölçeği | Altı arenayı; turnuva başarısının arena dışındaki tehdide bağlanmasını, rakiplerin baskısını, ayna rakibi ve final düellosunu anlatır. Bu kaynak anlatı/lore metnidir, görev listesi veya oynanış haritası değildir. | Altı özgün mekân ayrı ışık, renk, seyirci ve prop kimliği taşır. Anlatı ritmi yalnızca yapısal sinyal olarak kullanılır: lig kaydında tutarsızlık → ikinci kaynakla doğrulama → örüntü kanıtı → kamuya açıklama → final düellosu ve epilog. Kül Çemberi’nin ada ligi, kanıt nesneleri ve karakter kararları özgündür. [resmi Tome of Lore](https://swordsandsandals.com/) |
| Wiki rakip profilleri ekipman, özellik, büyü ve avantaj/dezavantaj tanımlar; #17 Nameless Shadow oyuncu yüklemesinin birebir kopyasıdır. Wiki bu aynalı savaşı bazen RNG’ye bağlı en zor rakip diye niteler. | Her rakibin tek baskı noktası ve en az bir görünür karşı oyunu içerik kartında bulunur. Şampiyonlar Yolu sonuna özgün bir Ayna Dövüşçü eklenir: oyuncunun yapı/ana silah arketipini yansıtır, stat aralığı normalize edilir, düşman hamleleri önceden okunabilir ve sonuç adil şekilde tekrar üretilebilir. Birebir eş statlı eşya kopyasıyla rastgelelik üzerine kurulu eşleşme alınmaz. [Wiki — Nameless Shadow](https://swordsandsandals.fandom.com/wiki/The_Nameless_Shadow), [Wiki — S&S II Bugs](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_II_Bugs) |

Bu plandaki 32 ana maç, 8 turnuva finali, 4 tek-seferlik hikâye seçimi, 16 sözleşme, 8 oyun sonu karşılaşması, 6 arena, 16 silah ve formül/ekonomi değerleri yeni oyunun önerilen üretim kapsamıdır; orijinal Classic veya Redux içeriklerinin bire bir sayımı değildir. Referansın adları, karakterleri, metinleri, sanat varlıkları ve özgün içerik listeleri kopyalanmayacaktır.

Bu plan aşağıdaki ürün kararlarını başlangıç varsayımı olarak kullanır:

| Karar | Üretim varsayımı |
|---|---|
| Platform | Android ve iOS telefonlar; Flutter tek uygulama kod tabanı |
| Ekran | Telefonlarda portre; tabletlerde uyarlanan geniş yerleşim |
| Oynanış | Sıra tabanlı, tek oyunculu, çevrimdışı tam kampanya |
| Kayıt | Cihazda otomatik kayıt; kampanya, envanter ve ayarlar sürümlü saklanır |
| Tam yayın kapsamı | 4 bölüm, 8 turnuva finali (4 bölüm şampiyonu), 32 ana karşılaşma, 4 tek-seferlik ara turnuva seçimi, 16 isteğe bağlı sözleşme, 6 arena, 8 ayrı oyun sonu karşılaşması; 4 silah ailesi |
| Seyirci Notu | Üç görünür maç koşulundan 0–3; en iyi puan kaydıyla devre armalarını açar, savaş/ekonomi dengesini değiştirmez |
| Maç süresi hedefi | Normal 4–6 dakika, elit 6–8 dakika, ara turnuva finali 7–9 dakika, bölüm şampiyonu 8–12 dakika |
| Görsel yaklaşım | Özgün, el çizimi hissi veren grafik 2D; fırtınalı ada ligi |
| Dil | Türkçe ve İngilizce metin altyapısı; ilk yayın için iki çeviri |
| Çevrimiçi özellikler | İlk sürüm için gerekli değil; tasarım çevrimdışı çalışır |

Bu varsayımlar tam oyun için önerilen başlangıç kapsamıdır; onaylanmış ticari karar değildir. Ürün sahibi kapsamı kilitlediğinde belge sürümlenir. Özellikle platform, kampanya uzunluğu, gelir modeli ve çevrimiçi kayıt değişiklikleri UX, teknik mimari, takvim ve içerik maliyetini etkiler. Bu planın teslim hedefi oynanabilir örnek değil; tüm içeriği, kalite kapıları ve mağaza paketleri tamamlanmış üründür.

### 1.3 Son kaynak çapraz kontrolünün üretim kararlarına etkisi

10 Ekim 2026 çapraz kontrolünde CrazyGames sayfasındaki Fandom bağlantısı görüldü; Fandom alt sayfaları doğrudan açma denemesinde robots/restricted yanıtı verdi. Arama dizini 18 numaralı Classic boss sırasını gösteriyor, fakat bu seçili Classic build üzerinde doğrulanmış bir kayıt değil. Geliştiricinin resmi Tome’u “20 notable Arena Champions” diyor; aynı bölümde 22 karakter maddesi görünüyor. Fearful Prisoner açılış tutorial rakibidir, Bhaargle kendini şampiyon gibi tanıtan ve maçı bilerek kaybeden bir cameo’dur; bunları dışarıda bırakınca 20 kalması makul bir açıklamadır, ama yazarın tanımladığı bir sayaç kuralı değildir. Tome ayrıca Sir Belgrave’in Classic’te rakip, Redux’ta NPC olduğunu söyler; lore listesi oyun sürümüne göre tam maç sıralaması değildir. İncelenen wiki tabloları da yedi giyilebilir zırh parçası ile ayrı kalkanı gösteriyor; “sekiz” savunma konumu kalkanı dahil sayarak açıklanabilir, ancak bu topluluk tablolarında ortak terim kullanıldığı veya Classic build’de doğrulandığı anlamına gelmez. Steam Redux içindeki Classic Edition ayarının da özgün Flash build’iyle eşdeğer olduğu varsayılmaz. Kesin Classic karşılaşma listesi ve mekanikleri ancak referans build sabitlenip oynanarak doğrulanabilir. [CrazyGames](https://www.crazygames.com/game/swords-and-sandals-2), [Wiki — Arena Bosses](https://swordsandsandals.fandom.com/wiki/Arena_Bosses), [Flash Gaming Wiki](https://flashgaming.fandom.com/wiki/Swords_And_Sandals_2), [resmi Tome of Lore](https://swordsandsandals.com/), [Redux Classic Edition duyurusu](https://store.steampowered.com/news/app/649600/view/4738306083312209369)

Bu belirsizlik üretim kararlarını değiştirmez; hangi verinin esin kaynağı, hangisinin kapsam kararı olduğunu netleştirir:

| Araştırma verisi | Üretime dönüştürülen karar |
|---|---|
| Topluluk boss kayıtları menzilli, büyücü, ağır vurucu, karma ve ayna rakibi gibi farklı dövüş baskıları gösterir; adlar, sıra ve sayılar build’ler arasında uyuşabilir. | 32 karşılaşma/8 final bu oyunun bağımsız kapsamıdır. Her finalin rolü, imza baskısı ve en az iki görünür karşı oyunu kendi level kartında tanımlanır; rakip adı, statı, eşyası, yetenek seti veya tasarımı alınmaz. |
| Resmi Tome’daki anlatı turnuva başarısından arena dışındaki gizeme, rakiplerin baskısına, oyuncunun kendisiyle yüzleşmesine ve final düellosuna yükselir. | Her 8 maçlık bölüm bir özgün hikâye izi taşır: #4’te ilk ödül tutarsızlığı, #12’de ikinci kaynakla doğrulama, #20’de örüntünün kanıtlanması, #28’de kanıtın açıklanması, #32/epilogda lig değişimi. Dört kayıt kartı sonuç/lig merkezi ekranlarında birer kez gösterilir; yeni keşif haritası veya zorunlu ara maç eklenmez. |
| Wiki Charisma’ya seyirci, taunt, ödül ve mağaza etkilerini birlikte atfeder; Classic build’de kesinliği düşüktür. | Savaş özellikleri sabit Sikke ödülünü, mağaza fiyatını veya Seyirci Notu kazancını artırmaz. Seyirci Notu yalnızca skor/kozmetik açar; her maçın ilk galibiyet ödülü sabit kalır ve tekrar galibiyet para çiftçiliği üretmez. |
| Resmi Tome altı arena sayar, ancak kaynakta arena çizimleri veya oynanış yerleşimleri verilmez. | Altı özgün sahne prop, ışık, renk ve seyirci silüetiyle ayrışır. Dört hikâye izi varlığı arka plan dekoruna gömülmek yerine okunabilir, erişilebilir ve yerelleştirilebilir mobil kayıt kartı olarak üretilir. |

## 2. Ürün tanımı

### 2.1 Kısa tanım

Oyuncu, fırtınalı bir ada kentindeki dövüş ligine katılan bir dövüşçü yaratır. Sıra tabanlı maçlarda rakiplerin niyetini okuyup hamle seçer; ödüllerle yedi özelliğini, yakın dövüş/yay silahlarını, büyülerini ve ekipmanını geliştirir; dört bölümdeki 32 ana karşılaşmayı ve sekiz turnuva finalini altı arenada tamamlayıp final şampiyonunu yener. Dört ara turnuva kararında altın ile özellik puanı arasında seçim yapar. Ardından 16 isteğe bağlı sözleşmeyi ve tekrar oynanabilir Şampiyonlar Yolu meydan okumasını açar.

### 2.2 Tasarım sütunları

1. **Karar okunabilirliği:** Her hamlenin isabet ihtimali, kaynak maliyeti ve savunma riski oyuncu hamleyi onaylamadan görülebilir.
2. **Anlamlı karakter yapıları:** Kuvvet, çeviklik, dayanıklılık, savunma ve büyü farklı oyun stillerine dönüşür; kampanyayı bitirmek için tek bir zorunlu yapı bulunmaz.
3. **Kısa, tamamlanmış oturumlar:** Oyuncu birkaç dakikada bir maçı bitirir; ödül, ilerleme ve sonraki hedef net biçimde gösterilir.
4. **Karakterli, mizahi dünya:** Abartılı dövüşçü portreleri, anonslar ve arena olayları ciddi rekabet ile hafif komediyi dengeler.

### 2.3 Hedef oyuncu ve başarı göstergeleri

Hedef oyuncu; kısa oturumlarda karakter geliştirme, sıra tabanlı taktik ve ekipman karşılaştırması seven mobil oyuncudur. Tam oyun öncesi kullanıcı araştırmasında ve tüm kampanyayı kapsayan kapalı testlerde aşağıdaki tasarım hipotezleri izlenir:

- Yeni oyuncuların en az %80’i ilk öğretici maçı oyun içi açıklamalarla tamamlayabilir.
- Oyuncu bir ekipmanı satın almadan önce temel saldırı/savunma farkını anlayabilir.
- Dört farklı yapı (kuvvet/savunma, çeviklik, isabet, büyü) tüm ana kampanyayı ve final meydan okumasını tamamlayabilir.
- Normal maçların medyan süresi 4–6 dakika aralığında kalır; uzun hamle dizileri ve ekran akışı mobil oturumlarda ayrıca ölçülür.
- Yenilgi oyuncuyu para veya ilerleme bakımından çıkmaza sokmaz.

Bunlar doğrulanmış sonuçlar değil; tam içerik üzerinde kapalı testte ölçülecek ürün hedefleridir.

## 3. Oyuncu döngüsü ve ekran akışı

### 3.1 Ana döngü

```text
Dövüşçü yarat
  → haritada sıradaki rakibi gör
  → rakibin niyetini incele
  → hamle seç ve maçı tamamla
  → sikke, deneyim ve seviye puanı al
  → dükkânda silah, zırh, büyü ve sarfı karşılaştır
  → özellikleri, ekipmanı ve bir sarf yuvasını ayarla
  → sonraki karşılaşmaya gir
```

### 3.2 Ekranlar

| Ekran | İçerik ve temel eylem |
|---|---|
| Açılış / devam | Devam et, yeni dövüşçü, ayarlar; son kayıt durumu |
| Dövüşçü yaratma | İsim, baş/saç, yüz kılı, ten, gövde oranı ve renk seçimi; başlangıç özellik puanları ve kısa yapı önerileri |
| Lig merkezi | Sıradaki düello, turnuva ağacı, dövüşçü durumu, altı arena rotası, dükkân ve antrenman girişleri |
| Rakip kartı | Rakip silüeti/portresi, davranış ipucu, önerilen seviye, ödül ve arena kuralı |
| Maç | Rakip ve oyuncu, sağlık/kaynak çubukları, rakip niyeti, hamle kartları, genişletilebilir savaş günlüğü |
| Sonuç | Kazanma/yenilgi, Sikke, XP, yeni seviye, sözleşme koşulu, turnuvadaki sonraki adım ve 0–3 Seyirci Notu gerekçeleri; #4/#12/#20/#28 sonrasında bir kez açılan hikâye izi kartı |
| Dövüşçü | Özellikler, yetenekler, ekipman yuvaları ve mevcut/sonraki değerler |
| Dükkân | Silah, zırh, büyü/tılsım ve sarf malzemesi; fiyat, gereksinim ve satın alma sonrası stat farkı |
| Ayarlar | Ses, titreşim, metin boyutu, azaltılmış hareket, dil, kayıt sıfırlama |

### 3.3 Akış ve kayıt noktaları

- İlk çalıştırmada dövüşçü yaratma ve öğretici maç doğrudan açılır.
- Her maç öncesi lig merkezine dönmek isteğe bağlıdır; sonuç ekranından sonraki maça geçiş açık bir düğmeyle yapılır.
- Maç sonucu, satın alma, özellik puanı harcama ve ayar değişikliği tamamlandığında kayıt alınır; hikâye izi kartının görüntülenme anahtarı da aynı güvenli yazımda saklanır.
- Uygulama kapanır veya arka plana giderse, açılışta son güvenli ekrandan devam edilir.
- Yenilgi, kampanyayı silmez; oyuncuya yeniden deneme ve mevcut sikkelerle hazırlanma olanağı verir.

## 4. Dövüş sistemi

### 4.1 Karşılaşma sırası

1. Maç açılışında arena kuralı ve rakip kartı gösterilir; iki dövüşçü de tam sağlık ve kaynakla başlar.
2. Her oyuncu turunun başında rakibin niyeti ve hedeflediği eylem kısa bir simge/metinle gösterilir.
3. Oyuncu bir hamle seçer. Onaydan önce başarı ihtimali, tahmini hasar ve kaynak maliyeti görünür.
4. Saf Dart dövüş çözücüsü oyuncu ve rakip eylemlerini belirler; animasyon katmanı bu sonuçları oynatır.
5. Durum etkileri uygulanır, kaynaklar yenilenir ve yeni tur başlar.
6. Sağlık sıfırlanırsa sonuç ekranına geçilir; eşitlik yoktur. Bir sonraki karşılaşma tam sağlık ve kaynakla başlar.

### 4.2 Başlangıç özellikleri

Özellik adları ve formüller bu projeye ait yeni sistemdir. Başlangıçta her özellik 2’dir; oyuncuya dağıtması için 6 ek puan verilir. Karakter yaratırken tek bir özellik 5’i geçemez. Karakter yaratma ekranında bir özelliğin etkisi kısa ve sayısal örnekle açıklanır. Kampanya seviyeleri boyunca özellik başına üst sınır 20’dir. Wiki’de Agility ile Attack ayrı özellikler olduğundan mobil sadeleştirme bunları tek bir “çeviklik” skoruna birleştirmez; İsabet saldırı başarısını, Çeviklik kaçınma ve konum eylemlerini yönetir.

| İç ID | Türkçe ad | Etki |
|---|---|---|
| `might` | Kuvvet | Yakın dövüş hasarı ve ağır hamle gücü |
| `agility` | Çeviklik | Kaçınma ve mesafe değiştirme eylemlerinin başarısı/maliyeti |
| `precision` | İsabet | Silah saldırılarının hedefi tutturma olasılığı |
| `vitality` | Dayanıklılık | Maksimum sağlık |
| `guard` | Savunma | Zırh etkinliği ve blok azaltımı |
| `stamina` | Kondisyon | Efor havuzu ve fiziksel hamleleri sürdürme |
| `arcana` | Büyü | Mana, büyü hasarı ve büyü savunması |

Bir seviye atlama 2 özellik puanı verir. Oyuncu her devre sonunda bir ücretsiz yeniden dağıtım hakkı alır; bu, yapı denemeyi teşvik eder.

### 4.3 Tuning için ilk formül seti

Aşağıdaki değerler tam oyun için başlangıç denge tabanıdır. Oyun içinde tek kaynak dosyasında tutulmalı; denge değişiklikleri veri güncellemesiyle yapılmalı, sürümlenmeli ve kampanyanın tamamında yeniden doğrulanmalıdır.

```text
Maksimum sağlık = 80 + 14 × Dayanıklılık + 2 × seviye
Maksimum efor   = 24 + 8 × Kondisyon
Maksimum mana   = 16 + 8 × Büyü
Başlangıç mesafesi = Orta

İsabet % = sınırla(
  75 + 1.25 × (saldıran İsabet − savunan Çeviklik)
      + hamle isabet değişimi + mesafe/durum değişimleri,
  en az 15, en çok 95
)

Temel hasar = silah gücü × hamle güç katsayısı + 1.6 × Kuvvet + hamle sabit bonusu
Etkin zırh = eşya zırhı + floor(0.7 × Savunma)
Son hasar = max(1, yuvarla(
  temel hasar × kritik çarpanı × 100 / (100 + etkin zırh) × blok çarpanı
))
Kritik % = sınırla(5 + 0.4 × (saldıran Çeviklik − savunan Çeviklik), 5, 25)
```

Kritik vuruş çarpanı kritik olmadığında `1.0×`, olduğunda `1.5×` olarak ayarlanır; zırh hesabından önce uygulanır. Blok çarpanı normalde `1.0`, gard etkisinde `0.55` olur. Çelme hamlesinde etkin zırh `0.65×` ile çarpılır. Mesafe `Yakın`, `Orta`, `Uzak` olmak üzere üç basamaklıdır. Silahların saldırı menzili eşya verisinde tanımlanır; menzil dışındaki fiziksel saldırı −30 isabet alır. Aile tablosunda belirtilen mesafe değerleri son toplam değişimdir ve genel −30 cezasıyla üst üste eklenmez. Mesafe değiştirme bir ana hamledir. Durum etkileri en fazla iki tur sürer ve üst üste sınırsız birikmez.

### 4.4 Hamle kataloğu

| Hamle | Efor/Mana | İsabet değişimi | Güç / etki | Öğrettiği karar |
|---|---:|---:|---|---|
| Hızlı vuruş | 5 efor | +10 | Silah gücünün 0.8’i | Güvenli ve kaynak dostu seçenek |
| Güçlü vuruş | 12 efor | −10 | Silah gücünün 1.5’i; %15 sendeletme | Büyük risk/büyük ödül |
| Gard al | 0 | — | Sonraki gelen hasar −%45; 4 efor kazan; menzilli atışlar da bu azaltıma tabidir | Rakip niyetine karşı savunma ve yaylı rakiplere ekipman satın almadan yanıt |
| Çelme | 8 efor | +0 | Gücün 0.65’i; zırhın %35’ini yok say | Zırhlı rakibe karşı seçenek |
| Menzilli atış | 6 efor + 1 fişek | Yay/mesafeye göre | Silah gücünün 1.0’ı; Yakın mesafede −15 isabet | Sınırlı atış hakkını ve mesafeyi yönet |
| Büyü | 8–16 mana | Büyüye göre | Büyü özelliği tabanlı; element etkisi | Kaynak yönetimi ve yapı farkı |
| Mesafe değiştir | 4 efor | — | Yakın/orta/uzak basamaklarından birine ilerle veya geri çekil | Menzil ve rakip telegraph’ını yönet |

Bir turda bir ana hamle yapılır. Her dövüşçünün kendi tur başında 4 efor, her üçüncü kendi turunda 2 mana yenilenir. Rakibin niyeti oyuncu hamlesinden önce görünür. İki saldırı aynı turda çözülüyorsa hamle kartındaki hız işareti sırayı belirler; eşitlikte oyuncu eylemi çözülür. Rakibin hareket eylemi de niyet kartında açıkça gösterilir. Yayın öncesi kademe 1–4 yay kapasitesi maç başına sırasıyla 3/4/5/6 fişektir; fişekler maç başında yenilenir, maçlar arasında taşınmaz ve para birimi değildir. Oyuncu ve rakip kalan fişek sayısını görür; rakip sıfıra düştüğünde menzili kapatma niyeti kullanır.

İlk altı büyü/özel yetenek:

| Kol | Yetenek | Maliyet | İsabet değişimi | Taban güç | Etki |
|---|---|---:|---:|---:|---|
| Kor | Köz Mızrağı | 8 mana | +5 puan | 4 | Tek hedef; `4 + 1.5 × Büyü` hasar |
| Kor | Kül Patlaması | 16 mana | −10 puan | 10 | Tek hedef; `10 + 1.5 × Büyü` hasar ve iki tur yanma |
| Gelgit | Siper Dalgası | 10 mana | — | — | `20 + 2 × Büyü` hasarını emen kalkan; saldırı vermez |
| Gelgit | Tuz Arındırması | 12 mana | — | — | Bir olumsuz durum etkisini kaldırır ve `8 + Büyü` sağlık yeniler |
| Rüzgâr | Çevik Esinti | 10 mana | — | — | Sonraki hamleye +8 isabet puanı; bir tur sürer |
| Rüzgâr | Kıyı Sıçrayışı | 12 efor | — | — | Mesafeyi bir basamak değiştirir ve sonraki gelen saldırının isabetini −10 etkiler |

Büyü hasarı `büyü taban gücü + 1.5 × Büyü` olarak hesaplanır, sonra hedefin büyü direnci uygulanır. Büyüler varsayılan olarak kritik vurmaz; kartta açıkça belirtilmedikçe durum etkisi de eklemez.

Durum etkileri başlangıçta sınırlı ve okunaklı tutulur:

| Durum | Etki | Süre / yığılma |
|---|---|---|
| Sendeleme | Sonraki hamlenin isabeti −10 | 1 tur; yenilenir, birikmez |
| Kanama | Her hedef turu başında yığın başına maksimum sağlığın %2’si kadar hasar | 2 hedef turu; en fazla 2 yığın; yeniden uygulanınca süre 2 tura yenilenir |
| Yanma | Her hedef turu başında yığın başına maksimum sağlığın %1,5’i kadar hasar | 2 hedef turu; en fazla 2 yığın; yeniden uygulanınca süre 2 tura yenilenir |
| Kırık gard | Etkin zırh −%20 | Başarılı Çelme uygular; takip eden bir tur boyunca etkin, yenilenir ve birikmez |
| Gard | Gelen hasar −%45 | Bir sonraki hasarda tüketilir |

Element direnci, ilgili durumun hasarını azaltır; bağışıklık ancak rakip kartında açıkça belirtilirse kullanılır. Her yeni etki oyuncuya simge, kısa metin ve kalan tur sayısıyla gösterilir.

### 4.5 Rakip yapay zekâsı

Rakip davranışı gizli zar hissi vermemelidir. Her rakibin bir arketipi ve açık tercih kuralı olur. Niyet tur başında, oyuncu hamle seçmeden hesaplanır; düşman aynı turdaki oyuncu seçimini görerek hile yapmaz:

- **Vurucu:** Eforu yeterliyse güçlü vuruşa yönelir; düşük sağlıkta gard alabilir.
- **Kalkanlı:** Sık gard alır; oyuncu önceki turda çelme veya büyü kullandıysa sonraki niyetinde karşı saldırıyı seçebilir.
- **Menzilci:** Fişeği varken yay atışını açık bir niyet kartıyla bildirir; cephanesi bitince oyuncuya doğru mesafeyi kapatmaya çalışır.
- **Çevik:** Düşük isabetli hamleleri kendi arketip bonusuyla karşılar; oyuncu önceki turda gard aldıysa hızlı saldırı niyetini seçebilir.
- **Mühürcü:** Mana harcamasını ve durum etkilerini belli eşiklerde kullanır.
- **Şampiyon:** Önceden görülen iki arketip kuralını sırayla birleştirir; yeni bir kuralı ilk kez final boss’ta öğretmez.

Her rakip kartı üretimde şu alanları içerir: seviye, arketip, sağlık/efor/mana, özellikler, ekipman, hamle havuzu, niyet ağırlıkları, karşılaşma öğretisi, ödül ve ses/görsel manifesti.

## 5. Kampanya ve level design

### 5.1 Kampanya yapısı

Tam yayın dört bölümde 32 zorunlu 1'e 1 karşılaşmadan oluşur. Her bölümde iki adet dört maçlık turnuva vardır; her turnuva üç eleme/lig düellosu ve bir finalle kapanır. Her bölümün ikinci turnuvasında bir normal rakip yerine iki elit sınama bulunur. Böylece bir bölüm dört normal, iki elit, bir ara turnuva finali ve bir bölüm şampiyonundan oluşur. #4, #12, #20 ve #28 ara final; #8, #16, #24 ve #32 bölüm şampiyonudur. Bir düello bittiğinde sonuç ve kayıt tamamlanır; oyuncu ana merkeze döner ve sonraki maça hazır, tam sağlık/efor/mana ile girer. Böylece turnuva ilerlemesi korunur ve mobil oturum kesintisi ceza yaratmaz. İlk maç (#1) öğreticiyi içerir, ayrı bir eğitim maçı yoktur; final şampiyon maçı #32'dir.

Wiki’nin daha yüksek seviye turnuvaları daha zor rakip ve daha çok ödülle açma tarifini mobilde yumuşatmak için ana rota düğümleri önceki karşılaşma tamamlanınca açılır; her rakip kartı önerilen seviyeyi gösterir ama seviye tek başına ana kampanyayı kilitlemez. Dükkân eşyaları bölüm/turnuva ilerlemesine ve açıkça gösterilen `minLevel`/`minAttribute` koşullarına bağlanabilir. Böylece oyuncu altın veya XP çiftçiliği yapmak zorunda kalmadan hikâyeyi bitirir; ilk kayıtta ve tekrar oynama senaryolarında bu kural doğrulanır.

32 ana rakip temel kadroyu oluşturur. 16 isteğe bağlı sözleşme mevcut rakiplerle şartlı tekrar düellolarıdır; sekiz Şampiyonlar Yolu karşılaşması bilinen rakiplerin ayrı ayarlanmış oyun sonu varyantlarıdır. Kapsam sayımı 40 savaş ayarı (32 ana + 8 oyun sonu) + 16 sözleşme kuralı = 56 savaş/kontrat kaydıdır. Dört ara-turnuva kararıyla toplam 60 üretim içerik kartı olur; bunlar 60 farklı düşman tasarımı değildir. Tamamlama ve kalite kabulindeki kayıt ayrımı §13.4’te sabitlenmiştir.

Her bölüm iki turnuvaya bölünür. İlk turnuva temel rolü öğretip #4 ara finalinde ilk kez sınar; ikinci turnuva bu rolü yeni baskılarla geliştirip #8 bölüm şampiyonunda birleştirir. Her dört maçta bir final kısa hedef/kapanış verir; her sekiz maçta bir büyük şampiyon bölüm anlatısını kapatır. Ara final 7–9 dakika, bölüm şampiyonu 8–12 dakika hedeflenir. Ana kampanyanın ilk tamamlanma süresi 4–6 saat; 16 sözleşme, dört ara-turnuva seçimi ve sekiz oyun sonu karşılaşmasıyla bütün içerik hedefi 7–9 saattir. CrazyGames sayfasının 9–10 saatlik tahmini yalnızca kıyas noktasıdır; farklı oynanış ve mobil oturum yapısı nedeniyle bu oyuna eşit süre şartı konmamıştır. Bu tahminler tam oyun kullanıcı testinde ölçülüp yeniden planlanır. [CrazyGames süre tahmini](https://www.crazygames.com/game/swords-and-sandals-2)

**Dünya:** Fırtınalı bir ada kentinin bazalt koylarında kurulan özgün bir dövüş ligi. Çalışma adı “Kül Çemberi”dir. Dört bölüm altı farklı dövüş mekânında ilerler: Kül Rıhtımı, Kor Ocağı, Fırtına Gözlemevi, Gelgit Amfitiyatrosu, Taç Kalesi ve Taç Halkası. Her bölümün ikinci yarısında arena değişimi, turnuva ayağındaki ilerlemeyi yeni bir sahne ve kural diliyle böler. Oyuncu dört ara finali ve dört bölüm şampiyonunu yener, final turnuvasını kazanır ve kısa bir epilogla hikâyeyi tamamlar. Altı mekân kararı resmi referans lore’undaki arena çeşitliliğinden esinlenen yeni ürün önerisidir; adlar, mimari, tarih ve görsel tasarım özgündür. [Resmi Tome of Lore](https://swordsandsandals.com/)

| Hikâye bölümü | Oyuncu hedefi | Ana anlatı dönüşü | Kapanış |
|---|---|---|---|
| Kül Rıhtımı | Lige kabul edil ve ilk şampiyonu yen | Lig halkın kutlaması gibi görünür; ödül dağıtımındaki usulsüzlük ilk kez fark edilir | Oyuncu ikinci devreye davet edilir |
| Kor Ocağı | Ocak işçilerinin ve dövüşçülerin güvenini kazan | Sözleşmeli dövüşlerin sonuçları lig yöneticilerince manipüle edilmektedir | Rakipler oyuncuya kayıtları verir |
| Fırtına Gözlemevi ve Gelgit Amfitiyatrosu | Kayıtları doğrula, şampiyonla karşılaş | Şampiyonların da aynı sistemin baskısı altında olduğu ortaya çıkar | Oyuncu final turnuvasına girerken kanıtı açıklar |
| Taç Kalesi ve Taç Halkası | Komutanı ve Çember Ustası’nı yen | Final şampiyonu yönetimle bağını kesmeyi seçer; oyuncu adil lig değişikliği için söz hakkı kazanır | Epilog oyuncunun ligde bıraktığı değişimi gösterir |

Hikâye ipuçları dört bölümde birer kez, sırasıyla #4, #12, #20 ve #28 sonuçlarından sonra verilir. İlki ödül kaydındaki tutarsızlığı, ikincisi başka bir kaynaktan doğrulamayı, üçüncüsü tekrar eden örüntünün kanıtını, dördüncüsü kanıtın açıklanmasını gösterir. #32 finali ve epilog, ligdeki değişimin sonucunu kapatır. Kart ekranda atlanabilir; ilerleme alanı ve gösterim anahtarı atomik kaydedilir, yeniden yükleme kartı ikinci kez oynatmaz.

### 5.2 Karşılaşma listesi

| # | Tür | Devre / arena | Rakip taslağı | Önerilen seviye | Öğretilen/ölçülen beceri | Arena kuralı | Ödül/ilerleme |
|---:|---|---|---:|---|---|---|
| 1 | normal | Kül Rıhtımı | İskele Kabadayısı, vurucu | 1 | Hızlı vuruş, gard, sağlık ve sonuç ekranı | Mekanik tehlike yok | Öğretici ödülü; ilk dükkân açılır |
| 2 | normal | Kül Rıhtımı | Halat Koşucusu, çevik | 2 | İsabet yüzdesi, silah menzili ve hamle karşılaştırma | Rüzgâr yalnızca görsel | İlk çevik silah seçeneği |
| 3 | normal | Kül Rıhtımı | Kapı Bekçisi, kalkanlı | 2 | Gard ve çelme ile zırhı aşma | Mekanik tehlike yok | İlk zırh karşılaştırması |
| 4 | ara final | Kül Rıhtımı | Tuz Kahini, büyücü | 3 | Rakip niyeti, gard zamanlaması | Tek seferlik, önceden işaretli dalga | İlk büyü ve yay kataloğu açılır |
| 5 | normal | Kül Rıhtımı | Halatçı Sefa, menzilci | 4 | Fişek sayacı, atış niyeti ve menzile göre silah seçimi | Tehlike yok | Kısa kılıç, mızrak ve yay karşılaştırması |
| 6 | elit | Kül Rıhtımı | Paslı Kanca, elit karşı hamleci | 5 | Niyet okuma, gard ve çelme birleşimi | Tehlike yok | Elit ödülü; ilk tılsım kataloğu |
| 7 | elit | Kül Rıhtımı | Fener Bekçisi, elit alan kontrolcüsü | 5 | İki turluk işaretli alan ve hamle sırası | Dalga önceden ilan edilir | Elit ödülü; rıhtım hikâye kaydı |
| 8 | bölüm şampiyonu | Kül Rıhtımı | Fener Şampiyonu | 6 | İlk devrede öğretilen tüm beceriler | İki faz; faz değişimi açıkça duyurulur | Devre 2 ve ikinci dükkân açılır |
| 9 | normal | Kor Ocağı | Cüruf Taşıyıcı, ağır saldırgan | 7 | Yüksek hasarı savunmayla karşılama | Buhar çıkışı tur önce işaretlenir | Ara seviye silah stoğu |
| 10 | normal | Kor Ocağı | Zincirci, durum etkili | 8 | Kanama/temizleme ve tur sayacı | Tehlike yok | Durum direnci ekipmanı |
| 11 | normal | Kor Ocağı | Örs Muhafızı, zırhlı | 9 | Çelme, büyü ve silah seçimi | Dar alan yalnızca görsel | Ara zırh seçeneği |
| 12 | ara final | Kor Ocağı | Sözleşmeli Düellocu, karma | 9 | Oyuncu yapısına göre taktik değiştirme | Önceden ilan edilen arena kuralı | Şampiyon öncesi hazırlık ödülü |
| 13 | normal | Kor Ocağı | Köz Gölgesi, karşı saldırgan | 10 | Rakibin güçlü hamlesini gard ile cezalandırma | Buhar çıkışı iki tur önceden belirtilir | Büyü direnci ekipmanı |
| 14 | elit | Kor Ocağı | Kızıl Ocak Şefi, elit alan kontrolcüsü | 10 | İşaretli tehlike ve kaynak zamanlaması | Buhar iki tur önceden belirtilir | Elit ödülü; ikinci seviye tılsım kataloğu |
| 15 | elit | Kor Ocağı | Kükürt Matronu, elit büyücü | 11 | Mana ve durum etkisi yönetimi | Alan etkisi iki tur önce bildirilir | Elit ödülü; yeni büyü seçeneği |
| 16 | bölüm şampiyonu | Kor Ocağı | Pirinç Muhafız, şampiyon | 12 | Kaynak ve ekipman yönetimi | İkinci fazda önceden görülen niyet dizisi | Devre 3 ve üçüncü dükkân açılır |
| 17 | normal | Fırtına Gözlemevi | Menzil Avcısı, mızrakçı | 13 | Menzil ve geri çekilme | Rüzgâr yalnızca hamle kartında gösterildiğinde etkili | Devre 3 silah stoğu |
| 18 | normal | Fırtına Gözlemevi | Ayna Kılıç, karşı hamleci | 13 | Rakip niyetini okuyup gard/çelme seçme | Mekanik tehlike yok | Devre 3 zırh seçeneği |
| 19 | normal | Fırtına Gözlemevi | Gelgit Mührücüsü, büyücü | 13 | Mana ve element direnci | İki turluk işaretli gelgit alanı | Devre 3 büyüsü |
| 20 | ara final | Fırtına Gözlemevi | Fırtına Avcısı, karma | 14 | Önceki sistemleri yeni sıra düzeninde kullanma | Tek, işaretli çevre olayı | Yeniden dağıtım hakkı |
| 21 | normal | Gelgit Amfitiyatrosu | Rüzgâr Seyircisi, çevik | 14 | Mesafe ve telegraph takibi | Görsel fırtına bilgiyi gizlemez | Elit öncesi ekipman hazırlığı |
| 22 | elit | Gelgit Amfitiyatrosu | Kıyı Orakçısı, elit mühürcü | 15 | Durum etkisini önleme ve karşı hamle | Alan etkisi bir tur önceden gösterilir | Elit ödülü; üçüncü seviye tılsım kataloğu |
| 23 | elit | Gelgit Amfitiyatrosu | Gelgit Yargıcı, elit büyücü | 16 | Büyü savunması ve kaynak yönetimi | Gelgit sırası simge/metinle açıklanır | Elit ödülü; final devresi hikâye kanıtı |
| 24 | bölüm şampiyonu | Gelgit Amfitiyatrosu | Gözlemci Başrahip, şampiyon | 16 | Menzil, büyü savunması ve faz yönetimi | İki faz; iki fazın da ipucu önceden verilir | Devre 4, final dükkânı ve hikâye düğümü açılır |
| 25 | normal | Taç Kalesi | Taç Muhafızı, zırhlı | 17 | Final ekipmanına karşı hasar türü seçimi | Güvenli, sabit zemin | Final güç seviyesi stoğu |
| 26 | normal | Taç Kalesi | Gölge Düellocu, çevik | 18 | İki turluk niyet dizisini tahmin etme | Görsel karartma bilgi gizlemez | Son çevik ekipman karşılaştırması |
| 27 | normal | Taç Kalesi | Sancak Cadısı, büyücü | 18 | Durum etkisi ve mana bütçesi | Sancak etkisi simge ve metinle açıklanır | Son büyü ve direnç seçeneği |
| 28 | ara final | Taç Kalesi | Demir Cellat, ağır vurucu | 18 | Gard, kaynak ve yüksek hasar yönetimi | Darbe alanı önceden işaretlenir | Final öncesi hazırlık ödülü |
| 29 | normal | Taç Halkası | Tahtsız Varis, çevik karma | 19 | Tüm önceki araçları oyuncu seçimine göre kullanma | Tehlike yok | İkinci elit öncesi son mağaza stoğu |
| 30 | elit | Taç Halkası | Kül Komutanı, elit karma | 19 | Temel karşı hamlelerin ve iki fazın sınanması | İki açık faz; yeni kural yok | Elit ödülü; yeniden dağıtım hakkı |
| 31 | elit | Taç Halkası | Mühür Kırıcı, elit büyücü | 20 | Yapı ve büyü savunması sınaması | Hedef değişimi önceden gösterilir | Elit ödülü; final şampiyon kartı açılır |
| 32 | bölüm şampiyonu | Taç Halkası | Çember Ustası, final şampiyonu | 20 | Tam kampanya finali; hasar, savunma, kaynak ve yapı sınaması | Faz geçişleri ve hedef değişimleri önceden gösterilir | Tamamlanmış son, epilog ve Şampiyonlar Yolu açılır |

Rakip adları, anlatı ve arena görselleri çalışma adlarıdır; içerik üretiminde tekil karakter ve görsel tasarım onayı gerekir. Her maçın zorluk dosyasında önerilen seviye, maç süresi, dört yapı üzerindeki sonuç, türüne göre kazanma oranı hedefi ve kayıt/ödül anahtarı bulunur. Her bölüm ayrı bir anlatı yayı ve ekipman açılımı taşır; altı arenanın her birinin kendi ışık, renk, seyirci, prop ve ambiyans seti vardır. Üçüncü ve dördüncü bölümde ikinci arena görsel dönüş görevi görür; dördüncü bölüm finali hikâyeyi kapatır.

### 5.3 Level design kuralları

- Bir karşılaşma en fazla bir yeni kural öğretir.
- Yeni kural önce güvenli örnekle görünür; aynı kural sonraki rakipte sınanır; şampiyon daha önce öğretilmiş kuralları birleştirir.
- Arena tehlikesi en az bir tur önceden işaretlenir ve yalnızca oyuncunun anlayabileceği bir karşı hamlesi varsa kullanılır.
- Oyuncu bir karşılaşmada yenilirse seviye, ekipman veya kampanya ilerlemesini kaybetmez.
- Her karşılaşma için rakip silüeti, portre, arena arka planı, giriş/çıkış, davranış, ödül ve ses listesi içerik kartında tanımlanır.
- İlk devrede rastgele arena kuralı yoktur. Rastgele içerik daha sonra eklenirse yalnızca kozmetik değişir veya sonuç oyuncu hamlesini anlamlı biçimde etkileyemeyecek kadar hafif olur.
- Ana kampanyada 32 karşılaşmanın tümü zorunlu olarak erişilebilir ve tamamlanabilir olmalıdır; isteğe bağlı sözleşmeler ana ilerlemeyi kilitlemez.
- Şampiyon fazları yeni mekanik öğretmez. Her faz geçişi metin, animasyon ve rakip niyet kartında aynı bilgiyi verir.
- 32 ana maç sekiz dört-maçlık turnuvaya ayrılır; #4, #12, #20, #28 ara finallerdir, #8, #16, #24, #32 bölüm şampiyonlarıdır. Bir bölüm dört normal, iki elit, bir ara final ve bir bölüm şampiyonu taşır; ekonomi ve içerik kartları aynı sayımı kullanır.
- Rakip rol eğrisi Dantus/Sagan/Spheracles/Gaiax/Sandalphon sayfalarındaki menzil, büyü, ağır hasar, çevikliği düşük güç ve karma yükleme profillerini kendi özgün düşmanlarına dağıtır. Her final rakip profili, imza baskısı, görünür zaafı ve en az iki yasal karşı hamle taşır. Ad, istatistik, ekipman ve hamle kopyalanmaz.
- Her bölümün ilk turnuva finalinden sonra (#4, #12, #20, #28) etkinin açıklandığı bir ara-turnuva kararı gösterilir. Seçim yalnızca bir kez yazılır, geri alınmaz ve ana kampanya kilidini değiştirmez; iki ödül yolunun da ekonomi/karakter testleri bulunur.

| Kaynaktaki rol sinyali | Yeni oyundaki karşılığı | Oyuncuya sunulan karşı oyun |
|---|---|---|
| Marksman Dantus: menzilli silah, hareket ve teleport büyüsü | Halatçı Sefa ile Menzil Avcısı: farklı menzil katmanlarında atış baskısı | Kartta fişek, menzil ve niyet görünür; Yakın mesafe, gard veya işaretli kaçınma ile yanıt verilebilir |
| Wizard Sagan: yüksek büyü, düşük fiziksel özellikler | Tuz Kahini ile Kükürt Matronu: tek büyük büyü/alan etkisi baskısı | Mühür/direnç ekipmanı veya görünür hazırlık turunda rakibin kaynak hamlesini cezalandırma |
| The Great Beast / Slave Driver / Gaiax: ağır kuvvet ve sağlık, düşük çeviklik ya da zayıf savunma | Cüruf Taşıyıcı, Kül Komutanı ve Demir Cellat: yüksek hasar, yavaş kurulum | Tehlikeli hamle telegraph edilir; mesafe değiştirme, gard ve durum etkisi seçenekleri |
| Spheracles: yüksek güç ve saldırı, daha ortalama çeviklik | Fener Şampiyonu: oyuncunun ilk bölgedeki araçlarını sınayan yakın dövüş zirvesi | Aşırı savunma yerine doğru sırada gard/çelme ve kaynak yönetimi |
| Sandalphon / Zeerzabahl: birden çok güçlü saldırı sistemi | Gözlemci Başrahip / Çember Ustası: geç oyunda iki rolü birleştiren fazlar | Faz değişimi ve hedef değişimi önceden ilan edilir; faz başına ayrı karşı hamle vardır |
| Nameless Shadow: oyuncu yüklemesinin aynası | Şampiyonlar Yolu #8 Ayna Dövüşçü | Yükleme görünür, değerler seviye aralığına normalize edilir, seed’li ve okunabilir niyet dizisi kullanılır |
| Antares: final düzeyinde çok yüksek teçhizatlı ve az açık veren rakip | Çember Ustası: ana kampanyanın finali | Hasar yarışı/stat duvarı yerine önceden gösterilmiş faz mekanikleri ve her yapı için birer yasal karşı hamle |

Bu tablo wiki’deki profil iddialarını yeni karaktere doğrudan kopyalamaz. Karakter sayfaları topluluk katkılı, bazıları taslak ve sürüm/istatistik tutarsızlıkları içerdiğinden rol sınıfları doğruluk iddiası değil, içerik çeşitliliği için üretim girdisidir.
- Her şampiyon öncesi oyuncu, şampiyonun ana baskısını, imza silahını ve önerilen karşı oyunu rakip kartında görür. Tek eşya veya özellik eşiği ana kampanyanın ilerleme kilidi olamaz.

### 5.4 Level kartı şablonu

Her level/maç kartı şu alanları doldurulmadan üretime alınmaz:

```text
Encounter ID / görünen ad:
Devre / arena / hedeflenen oyuncu seviyesi / içerik türü (normal-elit-şampiyon-sözleşme):
Yeni öğretilen beceri:
Hikâye izi tetikleyicisi, tek seferlik kayıt anahtarı, kart asset’i ve TR/EN metin anahtarı (uygulanıyorsa):
Rakip imza taktiği, görünür güçlü yönü ve oyuncunun kullanabileceği zayıf yönü:
Rakip seviyesi, özellikleri, ekipman/hamle seti ve içerik şartı doğrulaması:
Rakip rolü / imza silahı / birincil baskı / oyuncunun görünür karşı oyunu:
Oyuncu ekipmanı için minLevel ve minAttribute; karşılanmayan koşulun dükkân/kuşanım açıklaması:
Oyuncu ve rakip menzilli fişek bütçesi; menzil dışı eylemlerin engeli veya uyarısı:
Rakip arketipi ve niyet kuralları:
Oyuncuya gösterilen niyet/ipuçları:
Arena kuralı ve önceden haber verme biçimi:
Her üç mesafe durumunda yasal oyuncu/rakip eylemleri ve arena sınırı:
Gerekli/önerilen ekipman:
Dört yapı (kuvvet/savunma, çeviklik, isabet ve büyü) için beklenen süre, tur ve kazanma olasılığı:
Kazanç, XP ve kilit açma:
Üç açık Seyirci Notu koşulu; en iyi puan/kozmetik eşik anahtarı:
Önkoşul / başarısızlık sonrası akış / sonraki düğüm:
Gerekli görsel, animasyon, metin ve ses varlıkları:
Kabul koşulu ve denge notu:
```

### 5.5 İsteğe bağlı sözleşmeler ve oyun sonu

Her devrede dört isteğe bağlı sözleşme bulunur. Sözleşmeler yeni bir rakip kuralı öğretmek yerine mevcut hamle ve arena bilgisini farklı hedefle kullandırır. Her biri ilk tamamlamada sabit Sikke verir; tekrarlar para veya XP üretmez.

| ID | Devre | Sözleşme hedefi | Başarı koşulu | İlk tamamlama ödülü |
|---|---|---|---|---:|
| C1-A | Kül Rıhtımı | Temiz düello | İskele Kabadayısı’nı durum etkisi almadan yen | 60 Sikke |
| C1-B | Kül Rıhtımı | Kısa kılıç ustalığı | Halat Koşucusu’nu kısa kılıçla yen | 60 Sikke |
| C1-C | Kül Rıhtımı | Savunma sınavı | Kapı Bekçisi’ni en fazla 3 gard hamlesiyle yen | 60 Sikke |
| C1-D | Kül Rıhtımı | Fenerin gölgesi | Fener Bekçisi’nin iki işaretli alan turunda da hasar almadan kal | 60 Sikke |
| C2-A | Kor Ocağı | Kül kontrolü | Zincirci’yi kanama almadan yen | 90 Sikke |
| C2-B | Kor Ocağı | Zırh kırıcı | Örs Muhafızı’nı çelme veya büyü kullanarak yen | 90 Sikke |
| C2-C | Kor Ocağı | Isı yönetimi | Kızıl Ocak Şefi’ni işaretli buhar turunda hasar almadan yen | 90 Sikke |
| C2-D | Kor Ocağı | Matronun mühürleri | Kükürt Matronu’na bir büyüyle bir durum etkisi uygula | 90 Sikke |
| C3-A | Fırtına Gözlemevi | Menzil hâkimiyeti | Menzil Avcısı’nı menzil cezası almadan yen | 120 Sikke |
| C3-B | Fırtına Gözlemevi | Mühür bozma | Gelgit Mührücüsü’nün açıkça işaretlenmiş büyü hamlesine en az iki kez gard al | 120 Sikke |
| C3-C | Fırtına Gözlemevi | Kesintisiz tempo | Fırtına Avcısı’nı 8 tur içinde yen | 120 Sikke |
| C3-D | Gelgit Amfitiyatrosu | Yargıcın açığı | Gelgit Yargıcı’nı gelgit alanında tur harcamadan yen | 120 Sikke |
| C4-A | Taç Kalesi | Son hazırlık | Demir Cellat’ı kendi maksimum sağlığının en az %50’si kalmışken yen | 150 Sikke |
| C4-B | Taç Halkası | Komutanın açığı | Kül Komutanı’nın iki fazında da en az bir durum etkisi uygula ve kazan | 150 Sikke |
| C4-C | Taç Halkası | Şampiyon yemini | Çember Ustası’nı seçili silah ailesiyle yen | 150 Sikke |
| C4-D | Taç Halkası | Mührü kır | Mühür Kırıcı’nın işaretli büyüsünü en az iki kez gard ile karşıla | 150 Sikke |

Sözleşme hedefi sonuç ekranında maç başlamadan gösterilir; başarısız deneme ana kampanyayı veya temel maç ödülünü etkilemez. Son sözleşme, final karşılaşması açıldıktan sonra oynanabilir ve oyuncu bunu tamamlamak için finali tekrar edebilir.

**Ara turnuva kararları:** #4, #12, #20 ve #28 galibiyetinden sonra kısa bir hikâye olayı açılır. Her olayda oyuncu aşağıdaki yollardan birini seçer; kazanım seçim onayından önce gösterilir ve tek kullanımlık olay anahtarıyla kaydedilir.

| Olay | Antrenman seçeneği | Sponsorluk seçeneği | Kaydetme/denge kuralı |
|---|---|---|---|
| #4 sonrası | Seçilen bir özelliğe +1 kalıcı puan | +120 Sikke | İki seçenekten yalnızca biri |
| #12 sonrası | Seçilen bir özelliğe +1 kalıcı puan | +180 Sikke | İki seçenekten yalnızca biri |
| #20 sonrası | Seçilen bir özelliğe +1 kalıcı puan | +240 Sikke | İki seçenekten yalnızca biri |
| #28 sonrası | Seçilen bir özelliğe +1 kalıcı puan | +300 Sikke | İki seçenekten yalnızca biri |

İlk seçimden önce olay kapatılabilir; onaydan sonra seçim geri alınamaz. Aynı olay için uygulama yeniden açılışı, maç tekrarı veya yedek kayıttan devam ikinci ödül üretmez. Antrenman yolu dört ek özellik puanına, sponsorluk yolu en fazla 840 Sikke’ye çıkar; denge simülasyonu iki uç yolu ve aradaki 14 kombinasyonu kapsar.

**Şampiyonlar Yolu:** Finalden sonra açılan çevrimdışı, tekrar oynanabilir sekiz maçlık eleme serisi. Seviye 20’de mevcut rakip varyantlarıyla oynanır; yeni arena tehlikesi veya öğrenilmemiş kural eklemez. Her maç arasında otomatik kayıt ve ana merkeze güvenli dönüş bulunur; sağlık ve kaynaklar yeniden dolar, mobil oturum kesintisi seriyi bozmaz. Dört maç ve sekiz maç tamamlandığında birer kozmetik ödül açılır. Tekrar oynama Sikke/XP üretmez; en iyi tamamlama serisi yerel kayda yazılır. Son aşama **Ayna Dövüşçü** oyuncunun ana silah/ustalık arketipini yansıtır; karşılaşma öncesi yükleme ve rol gösterilir, rakip değerleri seviye 20 aralığına normalize edilir, hamle niyetleri deterministiktir. Böylece wiki’de anlatılan aynalı son rakip fikri uyarlanır, eş statlı kopyanın şansla belirlenen sonucu kullanılmaz. Ayna Dövüşçü oyuncunun kayıtlı dövüşçü görünüşünü/teçhizatını katmanlı olarak kullanır; bağımsız yeni karakter portresi gerektirmez. Çevrimiçi liderlik tablosu ilk yayın kapsamına girmez.

| Aşama | Rakip | Sınanan ustalık | Ödül/kayıt |
|---:|---|---|---|
| 1 | Paslı Kanca varyantı | Gard ve karşı hamle | En iyi seri kaydı |
| 2 | Kızıl Ocak Şefi varyantı | Buhar ipuçları ve kaynak yönetimi | En iyi seri kaydı |
| 3 | Fener Şampiyonu varyantı | İki faz ve öğretici hamleler | En iyi seri kaydı |
| 4 | Pirinç Muhafız varyantı | Durum etkileri ve zırh aşma | İlk dört maç kozmetiği |
| 5 | Kıyı Orakçısı varyantı | Büyü savunması ve mana bütçesi | En iyi seri kaydı |
| 6 | Gözlemci Başrahip varyantı | Menzil ve faz geçişleri | En iyi seri kaydı |
| 7 | Kül Komutanı varyantı | Rakip niyetleri ve iki fazlı karşılaşma | En iyi seri kaydı |
| 8 | Ayna Dövüşçü | Oyuncu yapısına karşı ekipman ve taktik ustalığı | Tamamlama kozmetiği ve en iyi seri kaydı |

## 6. Karakter, ekipman ve ilerleme

### 6.1 Dövüşçü yaratma

Oyuncu ad, baş şekli, saç/başlık, yüz kılı, ten tonu, vücut yapısı ve iki renk vurgusu seçer. Görünüş seçenekleri savaş performansını değiştirmez. İlk seçimden sonra görünüşü lig merkezinde ücretsiz değiştirebilir. Seçenekler birbirinden bağımsız katmanlar olarak birleştirilir; dövüş animasyonlarında yüz ve silüet okunaklı kalır.

Kampanya yedi harcanabilir savaş özelliği kullanır. Referans wiki’sindeki Charisma’nın tribün, taunt, ödül ve mağaza fiyatına bağlanan rolünden esinlenen **Seyirci Notu**, karakter özelliği değildir: maç sonunda brifingde önceden yazılmış üç koşuldan her karşılananı bir puan, en fazla 3 puan verir. Her maçta koşullar aynıdır ve yapılabilir: en az iki taktik yaklaşım kullanmak (saldırı, gard, konum değiştirme, büyü veya destek); gösterilen saldırı niyetine gardla karşılık vermek; arena tehlikesi olmayan maçta mesafeyi en az bir kez değiştirmek, tehlikeli arenada ise arena tehlikesinden hasar almadan çıkmak. Koşullar maça girmeden görünür; süre, hasar zarları veya gizli puan kullanılmaz. Yalnızca ana kampanya zaferlerinde her maçın en iyi notu saklanır; bölüm başına en fazla 24 puanın 16’sını toplayan oyuncu bir kozmetik arma açar. Sözleşme/ustalık maçlarının notu arma ilerlemesine yazılmaz. Ana ilerlemeye, savaş değerlerine, Sikke/XP kazancına etkisi yoktur.

### 6.2 Ekipman yuvaları ve silah aileleri

| Yuvalar | Etki |
|---|---|
| Ana silah | Hasar, menzil niteliği, hamle ailesi |
| Menzilli silah | Atış menzili, fişek kapasitesi; yay atışı hamlesini açar |
| Başlık | Kritik veya durum etkisine karşı küçük direnç; karşılaştırmada açıkça gösterilir |
| Gövde | Ana zırh/hasar azaltımı |
| Çizme | Mesafe değiştirme veya kaçınma hamlelerine küçük destek; hamle önizlemesinde gösterilir |
| Tılsım | Yapıya özgü bir küçük pasif |
| Sarf kemeri | Maç başına bir kez kullanılabilen, maç öncesi seçilen isteğe bağlı sarf eşyası |

Tam oyunda üç yakın dövüş ailesi (hızlı ve isabetli kısa kılıç, gard/sendeletme odaklı tokmak, mesafe ve karşı hamle odaklı mızrak) ile bir menzilli yay ailesi bulunur. Yakın dövüş ve menzilli silah ayrı yuvalara takılır; dört ailenin her birinde dört güç seviyesi vardır. Yay atışı Uzak ve Orta mesafede çalışır, Yakın mesafede −15 isabet alır ve maç başına kapasiteyle sınırlıdır. Aileler farklı oynanış sunar; doğrudan “daha pahalı = her durumda daha iyi” çizgisine bağlanmaz. Wiki’de daha çok ekipman yuvası ve silah kaydı bulunması, bu mobil sürümde aynı katalog büyüklüğünü gerektirmez; seçilen her yuva ve aile belirgin, önceden açıklanmış bir taktik rolü taşır.

Tam yayın kataloğu 16 silah (4 aile × 4 güç basamağı), 12 zırh parçası (başlık/gövde/çizme × 4 devre basamağı), 4 tılsım, 6 büyü/özel yetenek ve iki sarf eşyası ailesi içerir. Her eşyanın adı, fiyatı, varsa `minLevel` ve `minAttribute` koşulu, istatistik etkisi, taktik rolü, karşılaştırma metni ve görsel anahtarı katalogda tanımlanır. Oyuncu şartı karşılamıyorsa satın almadan önce nedenini ve gereken değeri görür; şart dışı eşya kuşanamaz. Düşman kartı aynı şema ile doğrulanır.

| Silah ailesi | Etkin mesafe | Davranış |
|---|---|---|
| Kısa kılıç | Yakın/Orta | Yakın mesafede +8 isabet puanı; Uzakta −30 |
| Tokmak | Yakın/Orta | Yakında +3 hasar; Uzakta −30 |
| Mızrak | Orta/Uzak | Uzakta +8 isabet puanı; Yakında −5 |
| Yay | Orta/Uzak | Yakında −15 isabet puanı; her atış 1 fişek harcar |

Tüm silah aileleri Orta mesafeden maça başlayabilir. Saldırı menzilinin dışında kalmak saldırıyı kapatmaz; isabet cezası ve silah kartında uyarı gösterilir. Her devredeki yay kademesi maç başına 3/4/5/6 atış verir; mühimmat otomatik yenilenir ve ayrı stok/sarf satın alımı gerektirmez. Wiki’deki Classic fişek eşikleri (9, 23, 28, 35 ve 45. seviyeler) 20 seviye sınırına uymadığı için devre eşiklerine çevrilmiştir.

### 6.3 Yetenek ve büyü

Altı büyü/özel yetenek, üç tematik kola ayrılır: kor, gelgit ve rüzgâr. Her kolda bir doğrudan hasar, bir savunma/kontrol seçeneği bulunur. Yetenek kartı efor/mana maliyetini, isabeti, durum etkisini, süresini ve direniş karşılığını gösterir. Wiki’de rapor edilen rastgele silah enchantment’ı ve değiştirilen etkinin bir sonraki maçta eski türle görünmesi riski ilk yayın sistemine eklenmez; element etkileri seçilebilir ve maliyeti önceden görülen büyü/tılsım eylemleridir. Tek kullanımlık şifa merhemi ile efor toniği, savaş öncesi sarf kemerine takılır; her maçta en fazla bir sarf eşyası ve bir kullanım vardır. İkisi de Sikke ile alınır, rastgele düşmez ve kampanyayı bitirmek için zorunlu değildir. Tam yayın için yetenekler ve sarf eşyaları veri tabanlı içeriktir; yeni içerik eklemek savaş çözücüsüne yeni ekran akışı eklemeyi gerektirmemelidir.

### 6.4 Ustalık ve antrenman

Lig merkezindeki antrenman ekranı, seviye ilerlemesinden gelen ustalık puanlarını harcar. Oyuncu 3, 6, 9, 12, 15, 18 ve 20. seviyelerde bir ustalık puanı kazanır. Her kolda üç düğüm bulunur; sonraki düğüm için önceki düğüm açılmalıdır. Yedi puan, bir dalı tamamlayıp başka bir daldan seçim yapmaya veya dalları karıştırmaya izin verir.

| Kol | Düğüm 1 | Düğüm 2 | Düğüm 3 |
|---|---|---|---|
| Ön saflar | Gard azaltımı +%5 | Güçlü vuruş zırhı +%10 daha çok yok sayar | Gard sonrası +2 efor kazan |
| Düellocu | Hızlı vuruş isabeti +3 puan | Mesafe değiştirince rakibin sonraki isabeti −10 | Rakip niyetine karşı gard sonrası sonraki hızlı vuruş kritik +5 puan |
| Mühürcü | İlk büyü isabeti +5 puan | Her üçüncü tur mana yenilemesi +2 | Yanma hasarı +%1 maksimum sağlık |

Bir pasif hamle kartında ve dövüşçü ekranında etkin olduğu değerle gösterilir. Yeniden dağıtım, devre sonu ücretsiz haklarından birini kullanır; ustalık ağacı da bu ekranda yeniden seçilebilir.

### 6.5 Seviye ilerlemesi

- İlk karakter seviyesi 1; final karşılaşması hedef seviyesi 20; seviye üst sınırı 20.
- Her seviye 2 özellik puanı verir.
- XP eğrisi: `sonraki seviye XP = 120 + 18 × (mevcut seviye − 1)`; seviye 1’den 20’ye ulaşmak toplam 5.358 XP ister.
- Ana kampanya ödülü: normal ve ara final karşılaşması bölüm sırasına göre 120/140/160/180 XP, elit 170/210/270/320 XP, bölüm şampiyonu 250/320/400/500 XP. Dört normal + bir ara final + iki elit + bölüm şampiyonu toplamı 6.410 XP’dir; final öncesi seviye 20’ye ulaşılır.
- XP eğrisi ve dağıtım, 32 ana karşılaşma, sekiz turnuva finali, dört yapı ve ara-turnuva ödül yolları üzerinde ekonomi simülasyonu ve tam oyun testinden sonra kilitlenir.
- 16 isteğe bağlı sözleşme Sikke ve kozmetik hedef sunar; seviye 20 sonrasında XP vermez. Şampiyonlar Yolu tekrar oynanabilir ama Sikke/XP çiftçiliğine izin vermez.

## 7. Ekonomi ve ödül dengesi

Bu ekonomi tek kazanılabilir para birimi kullanır: **Sikke**. İlk sürümde rastgele sandık, premium stat satışı veya ücretli savaş avantajı tasarımın parçası değildir. Dükkân stoğu deterministiktir; oyuncu satın almadan önce farkı görür.

### 7.1 Sikke kaynakları

| Kaynak | Devre 1 | Devre 2 | Devre 3 | Devre 4 | Kural |
|---|---:|---:|---:|---:|---|
| Normal galibiyet | 120 | 180 | 260 | 340 | Her maçın tam ödülü ilk galibiyette verilir |
| Ara final galibiyeti | 120 | 180 | 260 | 340 | #4, #12, #20, #28; normal galibiyetle aynı ödül, final kartı/kozmetik ayrıdır |
| Elit galibiyeti | 180 | 260 | 380 | 520 | Her bölümün ikinci turnuvasındaki iki elit; ödül ilk galibiyette verilir |
| Bölüm şampiyonu galibiyeti | 220 | 320 | 480 | 650 | #8, #16, #24, #32; bölüm kapanış ödülü |
| Bölüm ana rota toplamı | 1.180 | 1.740 | 2.540 | 3.390 | Dört normal + ara final + iki elit + şampiyon; ilk tamamlamada |
| Ara turnuva kararı | 120 | 180 | 240 | 300 | Antrenman seçilirse +1 özellik puanı, sponsorluk seçilirse Sikke; ikisi birlikte verilmez |
| Sözleşme ilk tamamlama | 60 × 4 | 90 × 4 | 120 × 4 | 150 × 4 | Her sözleşmenin ödülü bir kez verilir; yeniden deneme ödül üretmez |
| Başlangıç cüzdanı | 160 | — | — | — | İlk dükkânı göstermek için |
| İlk yenilgi desteği | Galibiyet ödülünün %30’u | Aynı | Aynı | Aynı | Yalnızca o maçın ilk yenilgisinde; sonraki galibiyette toplam ödül tavana tamamlanır |
| Şampiyonlar Yolu | — | — | — | — | Skor ve kozmetik hedef verir; tekrar Sikke/XP üretmez |

32 maçlık ana rota 8.850 Sikke, başlangıç cüzdanı ile 9.010 Sikke verir; dört ara kararda her seferinde sponsorluk seçilirse ana rota en fazla 9.850 Sikke üretir. On altı sözleşmenin tamamı bir kez bitirilirse, tüm sponsorluklar seçilmiş brüt üst sınır 11.530 Sikke olur. Dört antrenman seçimi bunun yerine dört özellik puanı verir. Bu üretim fiyatlar öncesi brüt kazançtır; gerçek harcanabilir bakiye satın almalara göre değişir. Fiyatlar bütün kampanyayı kapsayan simülasyon ve kapalı testten sonra kilitlenir.

### 7.2 Dükkân fiyat tabanı

| Seviye | Silah fiyat bandı | Zırh/aksesuar fiyat bandı | Büyü fiyatı | Sarf fiyatı (şifa/efor) | Açılma |
|---|---:|---:|---:|---:|---|
| Başlangıç | 160–240 | 80–140 | 140 | 55 / 45 | Devre 1 |
| Ara | 380–520 | 220–320 | 340 | 80 / 70 | Devre 2 |
| İleri | 820–1.050 | 480–680 | 700 | 115 / 100 | Devre 3 |
| Final | 1.600–2.200 | 950–1.350 | 1.400 | 150 / 130 | Devre 4 |

Önerilen ekonomi, her devrede yaklaşık iki anlamlı yükseltmeyi finanse edecek şekilde ayarlanır. Topluluk silah tablosundaki kılıç örnekleri 1.285–94.538 altın aralığına yayılır. Flash Gaming Wiki miğfer tablosunda Peasant 1.200 altın, seviye 48 Champions Helmet 187.500 altın olarak listelenir (156,25 kat artış); bu, 20. seviye tavanlı Kül Çemberi’ne taşınamayacak kadar uzun bir maliyet/yetki kuyruğudur. Aynı rehberde seviye 6 ve 12 miğfer fiyat örnekleriyle yedi giyilebilir zırh parçası ve ayrı kalkan kayıtları bulunur; kalkanı sekizinci savunma konumu saymak olasıdır, ancak kaynak terminolojisi ve build eşleşmesi doğrulanmamıştır. Tablolar kısmi ve sürüm doğrulaması olmadığı için doğrudan fiyat dayanağı olmaz; yalnızca referanstaki çok uzun seviye/teçhizat eğrisini gösterir. Kül Çemberi’nin fiyatları kendi ödül havuzuna, 20 seviye tavanına ve yaklaşık iki yükseltme hedefini koruyan dört basamaklı eğriye göre ayarlanır; Classic altın miktarları çevrilmez. Oyuncunun her yuvayı satın alması gerekmez; dükkân tek mobil merkezde silah, zırh, büyü/tılsım ve sarf sekmelerini sunar. Ekipman satış değeri satın alma fiyatının %50’sidir. Sarf fiyatları tablodaki şifa/efor sırasındadır: Şifa Merhemi maç içinde maksimum sağlığın %20’sini, Efor Toniği 10 efor yeniler. Her sarfın envanter sınırı 3, maç başına sarf kemeri kullanımı 1’dir; kullanım bir ana tur harcar. Satın alınan eşya, kuşanılmadan önce karakter ekranında karşılaştırılabilir. Final ekipmanı ve sarf eşyaları isteğe bağlıdır; hiçbir tek eşya finalin zorunlu anahtarı olamaz. İlk satın alma ve tüketim değerleri tam kampanya ekonomi simülasyonunda tekrar oynama/yenilgi senaryolarıyla doğrulanır. [Wiki — S&S II Weapons](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_II_Weapons), [Flash Gaming Wiki — armor guide](https://flashgaming.fandom.com/wiki/Swords_And_Sandals_2)

### 7.3 Kaynak/sink ve denge kuralları

| Ekonomi alanı | Üretim kuralı | Kontrol |
|---|---|---|
| Galibiyet | Tek seferlik tam maç ödülü | Maç tekrarı aynı ödülü sınırsız üretmemeli |
| Yenilgi | İlk denemede sınırlı destek | Üst üste kayıp, yükseltme almayı imkânsızlaştırmamalı |
| Dükkân | Sabit katalog ve fiyat; tek ekranda dört kategori | Tüm satın alımlar öncesi stat farkı görünmeli; satın alma onayı, para düşümü ve envanter ekleme tek atomik işlem olmalı; vazgeçme/başarısız işlem para ve envanteri değiştirmemeli; sarf alımları ilerleme için zorunlu olmamalı |
| Ekipman | Altı ekipman yuvası, sarf kemeri ve dört güç seviyesi | Yay ve yakın dövüş silahları dengeli olmalı; tek bir silah ailesi her karşılaşmada baskın olmamalı |
| Sarf tüketimi | Sikke ile tekil satın alma; envanter sınırı 3 | Kullanım envanterden bir adet düşürür; kalan stok ve kullanım kaydı güvenle saklanır, maç başı sınırı aşılmaz |
| Özellik puanı | Seviye ödülü | Her devre bir ücretsiz yeniden dağıtım hakkı |
| Savaş/ekonomi ayrımı | Harcanabilir özellikler yalnızca savaş değerlerini geliştirir; para ödülü ve mağaza fiyatı sabittir | Dört yapı ve 16 ara-seçim dizisinin her birinde aynı maçın ilk galibiyet ödülü eşit olmalı; özellik puanı veya Seyirci Notu Sikke/indirim üretmemeli |
| Seyirci Notu | Maç kartındaki üç görünür koşuldan karşılananlar | Her maç için en yüksek not bir kez kaydedilir; devre başına kozmetik arma açar, Sikke/XP üretmez ve tekrar maçla çiftçiliğe izin vermez |
| Ara turnuva kararı | Antrenman veya sponsorluk seçimi | Olay başına +1 özellik puanı ya da 120/180/240/300 Sikke; seçim kalıcı ve tekil |
| Tekrar oynama | Pratik ve ustalık için açık | İlk ödül tavanı aşılamamalı |

### 7.4 Denge çalışma kitabı

Tam içerik kilidinden önce ekonomi tablosu dört yapı (kuvvet/savunma, çeviklik, isabet, büyü) ve şu koşulları simüle eder:

- 32 ana maç, 16 sözleşme, dört ara turnuva kararı ve 8 meydan okuma aşamasında biriken XP, seviye ve Sikke;
- dört bölümde önerilen ekipman yükseltmesi ve final öncesi satın alma tercihleri;
- 16 olası ara-turnuva ödül dizisi (0–4 antrenman puanı veya en fazla 840 Sikke) ve her dizide yükseltmeye kalan bütçe;
- sözleşme ödüllerinin ana kampanya dengesi üzerindeki etkisi;
- şifa merhemi ve efor toniği fiyatları, envanter sınırı ve maç başı kullanımın yükseltme bütçesine etkisi;
- satın alma yapmayan, ortalama harcayan ve bütün parasını harcayan oyuncu;
- ilk denemede kaybetme ve birkaç kez tekrar deneme;
- her silah ailesi için hasar, isabet, süre ve sağlık kaybı;
- maç başına galibiyet oranı, tur sayısı ve kaynak harcaması.

Denge hedefi hipotezleri: normal rakiplerde ilk deneme galibiyeti `%75–90`, elitler ve ara finallerde `%60–75`, bölüm şampiyonlarında `%50–65`; dört yapı da kampanyayı ve final meydan okumasının en az ilk dört aşamasını tamamlayabilir; herhangi bir satın alma ana rota için zorunlu kilit değildir. İsabet/Çeviklik ayrımında hiçbir dağılım aynı anda isabet, kritik ve mesafe üstünlüğünün tümünü baskın biçimde almamalıdır. Bu oranlar tam içerik üzerinde oyuncu denemeleriyle güncellenir. Her ekonomi değişikliğinde fiyat/ödül tablosu ve simülasyon çıktısı aynı sürümde saklanır.

## 8. Görsel tasarım ve arayüz

### 8.1 Özgün sanat yönü

**Tema:** Fırtınalı ada liginde, bazalt koylara ve halat köprülere kurulmuş arena devreleri. Ana motifler rüzgâr halkaları, gelgit çizgileri ve dövüşçülerin abartılı silüetleridir.

**Stil:** El çizimi hissi veren grafik 2D; güçlü dış hatlar, kolay tanınan gövde/ekipman silüetleri, sınırlı dokulu yüzey ve okunaklı yüz ifadeleri. Mizah yüz ifadeleri, anons ve kısa sonuç metinleriyle verilir. Kaynak oyunun karakteri, arayüzü, arena planı veya görsel kompozisyonu kopyalanmaz.

| Rol | Renk | Kullanım |
|---|---|---|
| Mürekkep `#17232B` | Ana koyu | Metin, dış çizgi, karanlık yüzey |
| Kemik `#F5F0E6` | Ana açık | Kart, metin alanı, boşluk |
| Deniz camı `#286B66` | Soğuk vurgu | Savunma, gelgit, ikincil eylem |
| Kor `#B84E38` | Sıcak vurgu | Hasar, tehlike, saldırı |
| Pirinç `#D6AB55` | Ödül vurgusu | Sikke, şampiyonluk, nadir görünüm |

Altı arena kompozisyon, prop ve renk değerleriyle birbirinden ayrılır; kritik bilgi saklamak için karartma veya görsel gürültü kullanılmaz:

| Arena | Görsel imza | Sahne/ışık kuralı |
|---|---|---|
| Kül Rıhtımı | Bazalt basamak, halat ağları, tuzlu ahşap ve fenerler | Soğuk sis; oyuncu/rakip silüetleri açık kontrastta kalır |
| Kor Ocağı | Cüruf duvarları, döküm olukları, zincir ve örsler | Sıcak kor parlaması; tehlike alanı simge/çizgiyle belirtilir |
| Fırtına Gözlemevi | Kırık ölçüm halkaları, rüzgâr şeritleri, bakır göstergeler | Açık gri gökyüzü; rüzgâr efekti metin/telegraph üstünü örtmez |
| Gelgit Amfitiyatrosu | Kademeli su kanalları, deniz camı mozaik ve kabuk kemerler | Mavi-yeşil yansıma; gelgit sırası simge ve metinle tekrarlanır |
| Taç Kalesi | Taş payandalar, sancaklar, kuşatma kirişi ve muhafız korkulukları | Kemik grisi ve pirinç; karanlık alanlar hedefi gizlemez |
| Taç Halkası | Açık hava final çemberi, yükselen seyirci halkaları ve kırık taç motifi | Gün batımı pirinci; final faz geçişinde sahne ışığı değişir, savaş bilgisi sabit kalır |

Renk, tek başına sağlık, nadirlik veya durum anlamı taşımaz; simge, etiket ve şekil de eşlik eder. Yazı tipi seçimi Türkçe karakterleri ve tabular sayıları desteklemelidir. UI için okunaklı sans, başlıklar için sınırlı kullanımlı gösterişli yazı karakteri seçilir.

### 8.2 Portre ekranı düzeni

- Üst bölüm: maç/lig bağlamı, oyuncu ve rakip sağlık/efor değerleri; yay takılıysa iki tarafın kalan fişek sayısı.
- Orta bölüm: iki dövüşçü, rakip niyeti ve durum etkileri.
- Alt bölüm: sabit hamle alanı; ana seçenekler etiketli kartlar halinde. Sarf kemeri takılıysa tek kullanımlık eşyanın adı, etkisi ve kalan stoğu aynı alanda görünür.
- Savaş günlüğü ve ayrıntılı durumlar açılır panelde; ana hamle alanıyla yarışmaz.
- Dükkânda Sikke ve kategori sabit görünür; eşya kartı fiyatı, temel farkı ve satın alma eylemini aynı yerde gösterir.
- Lig merkezinde sıradaki maç ana eylemdir; dükkân ve karakter ekranları ikincil gezinme alanında kalır.
- Telefon ekranları güvenli alanlarla birlikte küçük/standart/geniş boyutlarda tasarlanır; tabletlerde bilgi panelleri genişletilir.

### 8.3 Üretilecek sanat varlıkları

Tam yayın için içerik kilidine girecek sanat varlık listesi:

- 1 katmanlı oyuncu dövüşçüsü: en az 8 baş/saç/başlık seçeneği, 4 yüz kılı seçeneği + sakalsız varsayılan, 8 ten tonu, 3 gövde oranı ve tüm ekipman yuvaları için eşleşen sprite katmanları;
- 32 ana rakip portresi (8 turnuva finali bunun alt kümesi), 16 sözleşme kartı illüstrasyonu, 4 ara seçim kartı görseli, 20 tekrar kullanılabilir rakip animasyon rig’i, 8 elit varyantı, 7 Şampiyonlar Yolu görünüş varyantı (aynı rig üstünde donanım/renk/efekt değişimi), oyuncu dövüşçü sprite’ından üretilen 1 Ayna Dövüşçü ve 8 final rakibine özgü giriş/zafer/yenilgi vuruşu; her rakibin rolü/imza silahı küçük ikonla tanınır, zırh/özellik verisiyle silüeti tutarlıdır;
- Dört dükkân kategorisini tanıtan özgün simge/tezgâh işaretleri; üç Seyirci Notu göstergesi, dört devreye ait kozmetik arma ve sonuç ekranı kalabalık tepkisi; mevcut arena sanat yönüyle uyumlu, oyunun kendine ait görsel tasarımı;
- Dört özgün hikâye izi kayıt kartı/nesne illüstrasyonu (ödül tutarsızlığı, ikinci kaynak, örüntü kanıtı ve halka açık açıklama); aynı mobil kart bileşeninde kullanılır, metinler görselden ayrı yerelleştirilir ve dört hikâye bölümünde birer kez gösterilir;
- 6 arena arka planı (Kül Rıhtımı, Kor Ocağı, Fırtına Gözlemevi, Gelgit Amfitiyatrosu, Taç Kalesi, Taç Halkası), her biri en az 4 ön/arka plan prop varyantı ve farklı ışık/atmosfer katmanlarıyla;
- 4 silah ailesi × 4 güç seviyesi, 3 zırh yuvası × 4 devre basamağı, 4 tılsım varyantı, 6 büyü kartı ve iki sarf eşyası ikonu;
- oyuncu animasyon durumları: bekleme, hazırlık, hızlı saldırı, güçlü saldırı, yay germe/atış, gard, sarf kullanımı, isabet, sendeleme, büyü, zafer, yenilgi;
- dört ana UI durum seti: normal, basılı, devre dışı, odak; efor/sağlık/durum ikonları;
- küçük efekt kütüphanesi: toz, metal darbesi, blok, yay mermisi, iyileştirme, rüzgâr, kor ve gelgit;
- 4 bölüm müzik teması, menü teması, dört bölüm şampiyonu teması/varyantı, dört ara-final anons/stinger varyantı, Şampiyonlar Yolu düzenlemesi ve temel UI/dövüş/sonuç sesleri.

Varlık adları manifestle tanımlanır. Her animasyon için isim, süre, olay kareleri (hasar/efekt), yön ve varsa ses olayı yazılır. Düzenlenebilir ana dosyalar saklanır; oyuna girecek şeffaf görsel/ses dışa aktarımları ayrı klasörde sürümlenir.

### 8.4 Uygulama kaydı (10 Ekim 2026)

Oyuncu için 1536×1024 RGBA, 3×2 şeffaf atlas üretildi ve savaş ekranına bağlandı. Hücreler sırayla bekleme, saldırı hazırlığı, kılıç darbesi, isabet tepkisi, gard ve zafer duruşudur. Saldırı, isabet, gard ve yenilgi olayları karşılık gelen geçici kareyi 320 ms içinde gösterip nötre döndürür; zafer duruşu sonuç görünümünde kalır. Hareket azaltma açıkken nötr kare korunur. Varlık `assets/art/manifest.md` içinde kaynak, ölçü ve hücre düzeniyle kayıtlıdır.

İkinci 1774×887 RGBA, 4×2 şeffaf atlas sekiz eylem pozu ekler: güçlü saldırı, yay germe, yay bırakma, kaçınma, sarf kullanımı, sendeleme, büyü ve yenilgi. Hücre sırası `HeroActionPose` eşlemesiyle sabitlenmiştir. Üst sıradaki çizimler nominal yarı-yükseklik çizgisini aştığından çizici hücreleri y=459’daki şeffaf aralıkta ayırır ve iki satırı aynı görüntü boyuna normalize eder; dört sütun şeffaf aralıklıdır. Savaş olayları güçlü saldırı/yay/büyü/sarf/kaçınma/darbe/yenilgi karelerini seçer; yay bırakma isabetli veya ıskalı atıştan sonra gösterilir. Tek karelik eylemler 320 ms sonra ana dövüş atlasının nötr karesine döner; yenilgi karesi sonuç görünümünde kalır. Saydamlık, gerçek görsel ölçüsü, satır/sütun kırpımı, manifest kaynağı, 0–7 kare eşlemesi ve widget çizimi doğrulanır.

1254×1254 RGBA eşya atlası 16 özgün kategori görselini içerir: dört silah ailesi, üç zırh yuvası, tılsım, altı büyü ve iki sarf. Buna 1536×1024 RGBA, 6×4 hücreli ikinci atlas eklendi; tier 2–4’teki sekiz silah/zırh/tılsım ailesinin 24 görseli ayrı ayrı katalog kartlarına bağlandı. Tier 1, büyüler ve sarflar ana atlası kullanır; tüm 32 ekipman satırı farklı kareye eşlenir ve atlas sınırları/widget çizimi testlidir.

Şampiyonlar Yolu’nun 8. aşaması için 1024×1536 şeffaf Ayna Dövüşçü portresi üretildi ve karşılaşma kimliği 40’a bağlandı. Son düello rakip istatistiklerini kayıtlı oyuncu yapısından 2–20 aralığında normalize eder; zırhı, ustalıkları ve uygun ana silahı kopyalar. Tohumlu aynı girdi aynı açılış niyetini ve ilk düşman eylemi sonucunu verir; regresyon testi bunu denetler. İlk yedi oyun sonu aşaması için 1536×1024, 4×2 özgün rakip atlası üretildi ve karşılaşma kimlikleri 33–39’a bağlandı; her aşama ayrı hücre kullanır, 40. karşılaşma Ayna Dövüşçü portresini kullanır. Atlas boyutu, yedi karşılaşma eşlemesi ve widget çizimleri testlidir. Oyuncu dövüşçüsünde kuşanılan zırhın görünürlüğü ve çekirdek özel UI glifleri §8.4’teki 10 Ekim 2026 uygulama kaydına eklendi; kalan rakip animasyon kapsamı ve görsel yayın işleri aşağıda listelenir.

Katmanlı oyuncu görünüşünün ilk üretim dilimi eklendi: 8 baş/saç/başlık, 5 yüz kılı durumu (sakalsız varsayılan dâhil), 8 ten tonu ve 3 gövde oranı. Atlaslar ve eşlemeleri `assets/art/manifest.md` içinde kayıtlıdır. Karakter yaratma ekranı seçimleri kayda yazar; dövüşçü ekranı aynı görünüşü gösterir. Kayıt şeması 9’a yükseltilmiş, eski kayıtlar sakalsız varsayılanla yükseltilir ve mevcut ilerleme korunur. Görünüş seçimlerinin hiçbir savaş/ekonomi etkisi yoktur. Fokus görünüş testleri atlas hücre/bounds eşlemesini, kaynak görselin çözülmesini, büyük önizlemede baş seçeneklerini ve yüz bölgesinde yüz kılı farkını doğrular.

§6.1’deki maç dışında ücretsiz görünüş düzenleme akışı dövüşçü ekranına eklendi: baş/saç, ten tonu, gövde oranı ve yüz kılı seçenekleri aynı ekranda önizlenir ve kaydedilir. Denetleyici yalnızca bu dört kozmetik kimliği yazar; test, XP, seviye, Sikke, özellikler, envanter, donanım, kampanya geçmişi, sözleşmeler ve diğer kayıt alanlarının aynı kaldığını, yeniden yüklemede görünüşün korunduğunu doğrular. Düzenleyici etiketleri TR/EN yerelleştirilmiştir. Savaş ekranı da kayıtlı dört görünüş kimliğini kullanır; varsayılan dışı görünüşte katmanlı karakter çizimi korunur ve genel savaş hareketi uygulanır. Bu katmanlı görünüşlerde poz-özel kahraman kare atlası henüz kullanılmaz. Mağaza satış akışı, `minAttribute` satın alma/kuşanma denetimleri ve sonuç ekranında tekrar maç ödülünün doğru gösterimi eklendi. Şeffaf 1280×1280 metal darbe efekti `BattleImpactEffect` olarak isabet/hedef olayına bağlandı. Savaş kurallarında yanma/kanama için ayrı süre ve yığın saklama, üçüncü turdaki mana yenilemesinin hamle önizlemesine katılması, öğrenilmemiş Kıyı Sıçrayışının engellenmesi ve başarılı oyuncu Çelmesinin Kırık Gard uygulaması eklendi; Kırık Gard bir sonraki tur boyunca etkin olur. Yanma 1,5%/hedef turuna dengelendi; 2 tur boyunca toplam hasar, dört yapı tam kampanya dengesini koruyacak şekilde doğrulanır. Kurtarılan geçerli yedeğin bozuk ana kayıttan sonra yazımda ezilmesi önlenmiştir. Dört bölüm şampiyonu için (maç 8/16/24/32) şeffaf 1536×1024 RGBA 3×2 savaş atlası üretildi; hazırlık/saldırı, isabet, gard ve yenilgi kareleri ortak rakip animasyon hattına bağlandı. Kuşanılan başlık/gövde/çizme katmanları §8.4’teki `FighterGearPainter` ile savaşçı görünüşüne çizilir. Özel UI ikon setinin ilk dilimi olan 14 Canvas glifi GameHub navigasyonuna ve ilişkili yuvalara bağlanmıştır; tüm durum/seyirci ikonları ve silah/arena başına VFX varyantları henüz tamamlanmamıştır.

10 Ekim 2026’da dört hikâye izi için şeffaf 1254×1254 RGBA atlası `assets/art/evidence/evidence_card_atlas.png` üretildi ve kampanya ekranına eklendi. Dört 627×627 hücre, #4/#12/#20/#28 tamamlandıkça sırayla açılır; ayrı Türkçe/İngilizce metin ve kart görseli gösterilir. Görüldü kimlikleri (`seenStoryEvidence`) kayıt şemasında saklanır; kart görülmeden sonraki iz gösterilmez ve yeniden açılışta kart tekrarlanmaz. Kayıt dönüşümü, sıra, yeniden yükleme ve paketlenmiş atlas için testler eklendi. Bu teslimat, §8.3’teki dört hikâye izi kartı maddesini tamamlar.

Aynı tarihte `assets/art/effects/combat_effects_atlas.png` adlı şeffaf 1774×887 RGBA 4×2 VFX atlası üretildi. Sekiz kare metal darbesi, toz, kalkan, ok, iyileşme, rüzgâr, kor ve gelgit efektlerini içerir; savaş olayları ve büyü türleri uygun kareyi seçer, hareket azaltma açıksa efekt gösterilmez. Kaynak görselin şeffaf köşesi, atlas boyutu, tüm kare eşlemeleri ve çizimleri otomatik test edilir.

10 Ekim 2026’da altı arena için ayrı 1536×1024 RGBA 2×2 prop atlası üretildi ve savaş sahnesine bağlandı. Her düelloda arena ve karşılaşma kimliğiyle iki farklı köşe prop hücresi seçilir; 768×512 hücreler karakter çiziminin arkasında, alt dış kenarlarda yer alır. Bunlar yeni tam sahne arka planları veya atmosfer katmanları değildir. Başlık, gövde ve çizme görselleri için 1448×1086 şeffaf 4×3 ekipman atlası üretildi; 12 hücre dört devre kademesini kapsar ve dükkân/satış kartlarında kullanılır. Bu önden görünümlü katalog kareleri savaşçıya gerilmez; savaşta başlık/gövde/çizme yuvaları dört kademe için eşleşen vektör katmanlarıyla çizilir. Dosyaların kaynakları, alfa bilgisi ve hücre eşlemeleri `assets/art/manifest.md` içindedir; tüm arena hücreleri ve 12 ekipman hücresi widget testlerinde çözülür ve boyanır. Kalan üretim işleri ana kadrodaki 16 rakibin çok kareli animasyonları, poz-özel kahraman kareleri, tüm durum/seyirci UI ikonlarının kapsanması ve silah/arena başına özel VFX varyantlarıdır.

## 9. Ses, anlatı ve erişilebilirlik

### 9.1 Ses

- Her bölüm için bir döngü müzik; dört bölüm şampiyonu için ayrı varyant, dört ara-final anonsu ve altı arena için ambiyans/seyirci katmanı.
- Saldırı, blok, büyü, durum etkisi, zafer, yenilgi ve menü eylemleri için kısa ses seti.
- Titreşim, saldırı ve ödül geri bildirimi için isteğe bağlıdır; ayarlardan kapatılabilir.
- Müzik ve ses efektleri ayrı ses düzeyine sahiptir; uzun süreli tekrarda yorucu olmayan miks hedeflenir.

**İlk üretim durumu (10 Ekim 2026):** 10 müzik döngüsü, 4 ara bölüm stinger’ı, 6 arena ambiyansı ve 18 SFX özgün, tekrarlanabilir sentez betiğiyle dışa aktarıldı. Uygulama kökünde tek bir ses yöneticisi; bölüm/şampiyon/Şampiyonlar Yolu müziği, arena eşlemeli ambiyans, kısa geçişler, savaş olayı SFX’leri, ayrı müzik/SFX düzeyleri, isteğe bağlı titreşim ve arka plan/ön plan durumunu yönetiyor. Ses tercihleri kayıt şeması 5’e taşındı; eski şema kayıtları varsayılanlarla yükseltiliyor. Varlık listesi ve yeniden üretim komutu `docs/audio-assets.md` içindedir. Son test ve yapı doğrulama sonuçları §13.5’te tutulur.

### 9.2 Anlatı

Hikâye, ada ligine katılım, dört bölümde sekiz turnuva finali ve Çember Ustası’yla son mücadeleden oluşur. Finalden sonra epilog, oyuncunun başarılarını ve ada ligi üzerindeki etkisini kapatır. Uzun ara sahneler yerine dört bölüme ait giriş/çıkış, sekiz final rakibi için kısa anonslar, maç öncesi rakip kartı, dört ara turnuva seçimi, 16 sözleşme metni ve maç sonu bir-iki cümlelik sonuç metinleri kullanılır. Şampiyonlar Yolu için de kısa özgün giriş/çıkış replikleri yazılır. Tüm karakter, mekân ve metin adları bu proje için özgün yazılır.

### 9.3 Erişilebilirlik ve yerelleştirme

- Sık kullanılan dokunma alanları Android’de en az 48 dp, iOS’ta en az 44 pt hedeflenir; her iki platform da güvenli alanları hesaba katar. [Android touch target](https://developer.android.com/guide/topics/ui/accessibility/views/apps-views), [Apple button hit region](https://developer.apple.com/design/human-interface-guidelines/buttons)
- Ekran okuyucu etiketleri, anlamlı odak sırası ve metin ölçeği %200’e kadar desteklenir.
- Hareket azaltma seçeneği, titreşim kapatma ve ses düzeyi ayrımı bulunur.
- Renk körlüğü/grayscale incelemesi yapılır; kritik bilgi renk dışı işaretle de gösterilir.
- Savaş animasyonunu hızlandırma/atlama seçeneği bulunur; sonuç bilgisi atlanmaz.
- Türkçe ve İngilizce metinler anahtarlarla yerelleştirilir; UI’da sabit piksel varsayımı yapılmaz.
- WCAG AA kontrast hedefinde normal metin en az 4.5:1, büyük metin en az 3:1 oranında kontrol edilir. [W3C WCAG 2.2 contrast minimum](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum)

## 10. Flutter teknik planı

Flutter’ın resmi mimari rehberindeki UI/veri katmanı ayrımı ve View/ViewModel/Repository yaklaşımı temel alınır. [Flutter uygulama mimarisi rehberi](https://docs.flutter.dev/app-architecture/guide)

### 10.1 Modüller

```text
lib/
  app/                 uygulama başlangıcı, tema, yönlendirme
  features/
    onboarding/        ilk açılış ve dövüşçü yaratma
    hub/               lig merkezi ve devre haritası
    battle/            savaş görünümü, ViewModel, animasyon bağlayıcısı
    character/          özellik, yetenek, ekipman
    shop/              silah, zırh, büyü/tılsım ve sarf katalogları; satın alma
    results/            ödül ve seviye akışı
    settings/           dil, ses, erişilebilirlik
  game_domain/
    models/             Fighter, Stats, Item, Encounter, Save
    combat/             hit chance, damage, AI, status, reward
    campaign/           devre, unlock ve encounter state
  data/
    repositories/       save, content, settings
    local_storage/      sürümlü yerel kayıt
  assets/
    content/            rakip, hamle, eşya ve ekonomi verisi
    art/ audio/          dışa aktarılan varlıklar
```

### 10.2 Sorumluluk sınırları

- **Flutter widget’ları:** ekran, kart, buton, erişilebilir etiket ve yerleşim.
- **ViewModel:** görünür ekran durumu, kullanıcı komutları, kayıt/sonuç geçişleri.
- **Saf Dart oyun alanı:** savaş formülleri, düşman kararları, XP, Sikke, kampanya kilitleri.
- **Görsel katman:** hareket ve efektler; oyun kuralı hesaplamaz, yalnızca dövüş olaylarını görüntüler.
- **Repository:** tek doğru kayıt kaynağı, kayıt sürümü, yükleme/kurtarma ve içerik erişimi.

Sıra tabanlı ve az aktörlü savaşta üretim tercihi Flutter animasyonları ve `CustomPainter`/sprite katmanıdır; hamle kartları ve erişilebilir arayüz Flutter widget’larında kalır. Tam savaş ekranının performans profili Flame gereksinimi gösterirse oyun sahnesi Flame’e taşınır, widget arayüzü overlay olarak korunur. Bu karar tam boyutlu içerik ve hedef cihaz profilinde alınır; ara buildler üretim ve kalite doğrulama içindir, mağaza yayını tam oyun kabul kapılarının geçilmesine bağlıdır. [Flame overlay belgeleri](https://docs.flame-engine.org/latest/flame/overlays.html)

### 10.3 Veri, rastgelelik ve kayıt

- Savaş çözücüsü sabit bir seed ile çalıştırılabilir; hata raporu aynı karşılaşmayı yeniden üretir.
- Savaş çözümü, animasyondan ayrı bir olay listesi üretir: `attackStarted`, `hit`, `blocked`, `statusApplied`, `turnEnded`, `rewardGranted`.
- Eşya, rakip, ödül, hamle ve seviye verisi oyun kodundan ayrılır; geçerli şema sürümüyle doğrulanır.
- Yerel kayıt `schemaVersion` taşır; uygulama güncellemesinde kayıt dönüştürücü ve yedekleme yolu bulunur.
- `seenStoryEvidence` ve kampanya ilerleme kimlikleri yerel kayıt şemasında sürümlü saklanır (güncel şema 8); maç sonucu, ilk galibiyet ödülü ve ilgili hikâye izi tek idempotent sonuç yazımında commit edilir.
- Kayıt, maç ortasında uygulama kapanırsa tur başı güvenli durumuna döner; sonuç/ödül/hikâye olayı iki kez yazılmaz.
- İlk yayın tam oynanabilirliği ağ bağlantısına bağlamaz.

## 11. Üretim yol haritası ve teslim kapıları

| Aşama | Önerilen süre* | Ana iş | Çıkış ölçütü |
|---|---:|---|---|
| 0. Kapsam ve üretim kilidi | 4 hafta | Ürün varsayımları, 32 ana maç/8 final/16 sözleşme/4 hikâye seçimi kartı/#4, #12, #20 ve #28 için 4 hikâye izi olayı, yedi özellik, hikâye sonu, ekonomi tablosu, tam asset manifesti, tüm ekran akışları | Kapsam kararı, kabul ölçütleri, içerik/teknik şemalar ve iş listesi onaylı; kapsam dışı işlerin değişiklik süreci tanımlı |
| 1. Üretim temeli | 5 hafta | Savaş çekirdeği, içerik yükleme, kayıt/migrasyon, kampanya haritası, mağaza/karakter/ayar ekranlarının çalışan ürün temeli, hedef cihaz profili | Baştan sona üretim mimarisi çalışır; seed’li savaş, atomik ödül ve içerik doğrulaması güvenilir; bu aşama kullanıcıya oyun teslimatı değildir |
| 2. Tam içerik üretimi | 19 hafta | Altı arena/dört bölüm, 32 ana karşılaşma ve 8 final set-piece’i, 4 hikâye seçimi, #4/#12/#20/#28 sonrası 4 hikâye izi kartı, 16 sözleşme, 8 Şampiyonlar Yolu maçı, 16 silah, sarf kataloğu, sanat/ses/anlatı/yerelleştirme | İçerik manifestindeki her kayıt doldurulmuş ve oyunda açılabilir; her arena, turnuva finali ve bölüm kendi görsel/mekanik kimliğine sahip |
| 3. Tam oyun Alpha | 6 hafta | Tüm ekranlar ve içerik uçtan uca bağlanır; kayıt yükseltme, ekonomi, ara seçimler, sözleşmeler, epilog ve 8 aşamalı oyun sonu dahil tam kampanya | Yeni kayıtla 32 ana maç, 4 seçim, 16 sözleşme ve 8 meydan okuma aşaması tamamlanabilir; içerik kilitleri/ödüller doğru; bloklayan hata kalmamış |
| 4. İçerik kilidi ve Beta | 6 hafta | Tam denge, cihaz matrisi, erişilebilirlik, performans, dört yapı, TR/EN son okuma, ses/art son düzenleme ve regresyon | Yer tutucu/eksik içerik yok; dört yapı kampanyayı bitiriyor; kayıt, erişilebilirlik ve teknik kabul koşulları geçilmiş |
| 5. Yayın adayı ve mağaza hazırlığı | 3 hafta | İmzalı Android/iOS paketleri, mağaza metni/görseli, uygulama simgesi, gizlilik/veri beyanları, destek ve kurtarma prosedürü | Temiz kurulum, güncelleme, kayıt devamı ve mağaza kontrol listesi onaylı; yayınlanabilir nihai paket üretilmiş |
| 6. Yayın ve bakım | Sürekli operasyon | Hata takibi, oyuncu geri bildirimi, uyumluluk ve isteğe bağlı içerik sürümleri | Sürüm notları, destek akışı ve geri alma planı; her yama yayın kabul kapılarından geçer |

*Süreler 6–8 kişilik çekirdek ekip ve paralel sanat/içerik üretimi varsayımıyla yaklaşık 43 haftalık temel takvimdir. %15 risk payıyla planlama ufku yaklaşık 50 haftadır; bu, onaylanmış yayın tarihi değildir. Gerçek ekip ve bütçe belli olunca güncellenmelidir. Tek kişi veya küçük ekip için aynı kapsam önemli ölçüde daha uzun sürer; takvim ve kaynak varsayımı yeniden hesaplanmalıdır. Alpha/Beta ekip içi kalite kapılarıdır; kullanıcıya sunulacak sonuç yalnızca tüm kabul koşullarını geçen tam sürümdür.

## 12. Üretim rolleri ve iş paketleri

| Rol | Sahip olduğu çıktı |
|---|---|
| Ürün/oyun tasarımcısı | Oyun hedefi, bütün kullanıcı akışları, mekanik spesifikasyon ve kapsam değişikliği |
| Level designer | 32 ana maç, 8 turnuva finali, 4 hikâye seçimi, #4/#12/#20/#28 için 4 hikâye izi olayı, 16 sözleşme ve 8 Şampiyonlar Yolu kartı; turnuva ilerlemesi, altı arena, öğretim sırası, zorluk ve şampiyon fazları |
| Ekonomi tasarımcısı | XP/ödül/fiyat çalışma kitabı, 16 ara-seçim ödül dizisi, kaynak/sink analizi, dört yapı simülasyonu |
| Flutter geliştiricisi | Tüm ekranlar, durum akışı, erişilebilirlik, uygulama entegrasyonu ve mağaza build’leri |
| Oyun sistemleri geliştiricisi | Saf Dart savaş/AI/ilerleme ve içerik veri şeması |
| UI/2D sanatçı | Görsel yön, tüm UI, 32 rakip portresi, 6 arena, dört hikâye izi kartı, dövüşçüler, dört silah ailesi, sarf ikonları ve animasyon |
| Teknik sanatçı | Dışa aktarım, manifest, atlas/bellek bütçesi ve varlık doğrulama |
| Ses tasarımcısı/anlatı yazarı | Dört devre müziği, şampiyon temaları, ses seti, oyun içi metinler ve epilog |
| QA | 32 maç, 4 tekil hikâye izi, 16 sözleşme, 8 meydan okuma, altı arena, menzilli silah/mühimmat, sarf ve ekonomi senaryoları, cihaz matrisi, kayıt ve erişilebilirlik doğrulaması |

Tek kişi birden çok rol üstlenebilir; ancak tasarım kartı, asset manifesti ve ekonomi tablosu yine ayrı teslimatlar olarak tutulmalıdır.

## 13. QA, denge ve yayın kabul koşulları

### 13.1 Oynanış kabulü

- Yeni kurulumdan final ve epiloga kadar ana kampanya tamamlanabilir; ardından 16 sözleşme ve Şampiyonlar Yolu açılır.
- 32 karşılaşmanın her biri doğru rakibi, arena kuralını, ödülü ve sonraki kilidi gösterir; 16 sözleşme ve 8 meydan okuma aşamasının tümü doğru koşul/ödül durumunu kaydeder.
- Yenilgi sonrasında ilerleme korunur; oyuncu kampanyayı tekrar oynayabilir.
- Her hamle kartı maliyet, isabet, kalan fişek ve etkisini hamle öncesi doğru gösterir.
- Yakın/Orta/Uzak mesafelerin her birinde en az bir yasal oyuncu eylemi vardır; hamle paneli mesafe ve kaynak değiştikten sonra güncellenir, geçersiz eylem çözücüye ulaşmaz.
- Mağaza satın alımı onaylandığında bakiye ve envanter birlikte güncellenip kaydedilir; iptal/başarısız işlem ikisini de değiştirmez. Uygulama satın alma sırasında kapanırsa açılışta çift harcama veya ücretsiz eşya oluşmaz.
- Rakip içerik verisindeki seviye/özellik/teçhizat şartı doğrulanır; karşılaşma açıldığında rakip envanteri ve statları içerik kartıyla aynıdır. Kural dışı bir boss yüklemesi gerekiyorsa yalnızca `bossOverride` alanıyla açıkça tanımlanır; gizli şart dışı eşya/istatistik olmaz.
- Silah satın alma/kuşanma `minLevel` ve `minAttribute` koşullarını aynı katalog kaydından denetler; kart gereken koşulu gösterir, geçersiz satın alma kuşanılmış öğe veya bakiye üretmez.
- Büyü ve tılsım için `minLevel`/`minAttribute` uygunluğu dükkân, savaş hazırlığı ve maç başında aynı veri kaydından denetlenir; kilitli içerik savaş hamlesi olarak seçilemez ve gereken Büyü/seviye değeri önceden görünür.
- Her büyü, üç mesafe bandında ve her silah ailesi takılıyken kendi tanımlı hedefleme/menzil kuralını izler; silah seçimi büyünün menzilini sessizce değiştirmez. Sarf kullanımı sıfır kaynak, tam kaynak ve sınır değerlerinde doğru sonucu verir; etkisiz veya geçersiz kullanım eşya/kaynak tüketmez.
- Arena konumu tanımlı sınırlar içinde tutulur; menzilli hasar, zırh ve blok uygulandıktan sonra içerik/savaş sınırlarını aşamaz.
- Savaş tekrar kaydı/seed’iyle aynı çözüm ve olay dizisi elde edilir.
- Dört yay kademesinin fişek kapasitesi 3/4/5/6 olarak doğru yenilenir; maç bitince kullanılmayan fişek ne taşınır ne ödüle dönüşür.
- Sarf kemerindeki eşya maç başına en fazla bir kez kullanılır; şifa/efor sonucu ve envanter adedi kayıtla tutarlıdır.
- Her maçın Seyirci Notu üç açık içerik koşulundan tekrar üretilebilir; kayıt en yüksek puanı korur, not Sikke/XP veya savaş bonusu vermez, düşük not ana kampanya/kontrat erişimini kilitlemez.
- #4/#12/#20/#28 sonrası dört hikâye izi kartı doğru sırada ve bir kez görünür; atlama, uygulamayı kapatıp açma, dil değişimi veya maç tekrarı kaydı çift olay üretmez ve sonraki karşılaşmayı kilitlemez.
- Her maç sonrasında turnuva ilerlemesi güvenli kaydedilir; uygulama kapanıp açıldığında ana merkeze ve sıradaki doğru düelloya dönülür.
- #4/#12/#20/#28 ara final, #8/#16/#24/#32 bölüm şampiyonu olarak doğru kaydedilir; her dört maçlık turnuva finalle biter, ama finali kaybetmek kampanya ilerlemesini silmez.
- Her ara-turnuva seçiminde etkiler onay öncesi gösterilir, tekil olay anahtarıyla bir kez yazılır; uygulama kapanışı veya yükleme/maç tekrarı ikinci özellik puanı ya da Sikke üretmez.
- İsabet ve Çeviklik ayrı değerlerdir; kart, karakter yaratma ve hamle önizlemesi bu ayrımı doğru gösterir. Kuvvet/savunma, çeviklik, isabet ve büyü yapıları tek bir zorunlu ekipmana bağlı kalmadan tüm ana kampanyayı tamamlayabilir.
- Şampiyonlar Yolu 8. aşamadaki Ayna Dövüşçü ana silah/ustalık arketipini girişteki kayıt anlık görüntüsünden alır; bu karşılaşmada değerler normalize edilir, rakip niyet dizisi seed ile tekrar üretilebilir ve dört temel yapının her biri için test edilen bir karşı oyun vardır.

### 13.2 Ekonomi kabulü

- Ödül tekilleştirme açık; tekrar kazanma/yenilme Sikke ve XP’yi sınırsız üretmez.
- İlk yenilgi desteği, oyuncuyu bir dükkân yükseltmesine yaklaştırır ve toplam maç ödülü tavanını aşmaz.
- Dört yapı ve 16 ara-turnuva seçim dizisi için ekonomi tablosu 32 maç boyunca negatif bakiye veya ilerleme yumuşak kilidi göstermiyor; sözleşme ödülleri ve olay kararları oyun sonu tekrarlı para/özellik üretmiyor.
- Eşya satın alma, satış, kuşanma ve sarf tüketiminde bakiye/envanter tek bir tutarlı sonuca ulaşır; iptal, uygulamanın arka plana alınması ve yeniden açılması çift işlem veya veri kaybı üretmez.
- Sarf eşyaları tekrarlı maç ödülü/yenilgi parası üretmiyor; envanter sınırı, maç başı kullanım ve mağaza fiyatları tüm harcama profillerinde doğru çalışıyor.
- Her devrede en az iki anlamlı ekipman tercihi vardır; mağaza seçimleri karşılaştırılabilir.
- Denge çalışması her değişiklik sonrası kaydedilir ve sürüm numarasıyla oyuna aktarılır.

### 13.3 Mobil/teknik kabulü

- Portre ekranı küçük, standart ve büyük telefonlarda; tablet yerleşimi ayrı kontrol edilir.
- Sık kullanılan dokunma alanları Android’de en az 48 dp, iOS’ta en az 44 pt hedeflenir; güvenli alanlar ve düğmeler arası boşluk korunur. [Android touch target](https://developer.android.com/guide/topics/ui/accessibility/views/apps-views), [Apple button hit region](https://developer.apple.com/design/human-interface-guidelines/buttons)
- TalkBack/VoiceOver ile ana eylemler adlandırılmış ve doğru sırada odaklanır.
- Hareket azaltma seçeneğinde savaş sonucunu anlamak mümkün kalır.
- Düşük/orta seviye hedef cihazda savaş animasyonları 60 FPS hedefiyle profillenip ölçülür; altı arena, 32 ana rakip ve dört silah ailesinin bellek/indirme boyutu profili içerik kilidinde doğrulanır ve yayın bütçesini aşmaz.
- Uygulama arka plana alınıp tekrar açıldığında son güvenli kayıt yüklenir; eski kayıt şeması kontrollü yükseltilir.
- Kayıt geri yükleme, bozuk/eksik alan ve işlem yarıda kalma durumları test edilir; bozuk kayıt son güvenli yedekten kurtarılır veya kullanıcıya güvenli hata/yeniden başlatma yolu sunulur.
- Yayın adayında kritik/bloker hata yoktur; mağaza varlıkları, imza, gizlilik metni ve destek adresi hazırdır.
- Uygulama simgesi, açılış görseli, ekran görüntüleri, mağaza açıklamaları, yaş derecelendirmesi ve gerekli platform beyanları eksiksizdir; yayın paketinde test amaçlı/yer tutucu metin ve varlık bulunmaz.

### 13.4 Tam oyun çıkış kapısı

- İçerik manifestinin %100’ü yayındaki sürüme bağlıdır: 32 ana karşılaşma, 16 sözleşme kaydı, 8 oyun sonu karşılaşma kaydı ve 4 ara-turnuva seçimi; toplam 60 üretim kartı. Bunların 40’ı savaş ayarı, 16’sı sözleşme kuralı ve 4’ü seçim olayıdır. #1 öğretici maçıdır, ayrıca bir maç sayılmaz; #32 finaldir. Sözleşmeler ana kadroyu yeniden kullanır; Şampiyonlar Yolu sekiz rakip varyantıdır. Toplamda 32 temel rakip tasarımı, 4 ara final, 4 bölüm şampiyonu, 6 arena, 16 silah, 12 zırh, 4 tılsım, 6 büyü, 2 sarf ailesi, katmanlı oyuncu görünüşü (8 baş/saç, 5 yüz kılı durumu, 8 ten tonu, 3 gövde oranı), 4 Seyirci Notu kozmetik arması ve 4 hikâye izi kartı tamamlanır.
- Her dört maçlık turnuva üç eleme/lig düellosu ve bir finalle kapanır; #4/#12/#20/#28 ara final, #8/#16/#24/#32 bölüm şampiyonudur. Her bölüm dört normal, iki elit, bir ara final ve bir bölüm şampiyonu içerir; arka arkaya rakip dalgası yoktur. Maç sonuçları, ara seçim ve sıradaki turnuva adımı güvenli kaydedilir.
- Temiz kurulumla karakter yaratmadan 8 turnuva finali, 4 ara seçim, epilog ve oyun sonu meydan okumasına kadar ilerleme tamamlanır; kapalı test kayıtları güncelleme sonrası da açılır.
- Eksik/yer tutucu ekran, metin, sanat/ses varlığı, çalışmayan düğme veya sonradan tamamlanacak içerik yoktur.
- Yayın engelleyici ya da yüksek öncelikli bilinen hata, veri kaybı veya kampanya ilerlemesini kilitleyen durum yoktur.
- Android/iOS mağaza dosyaları, imza, gizlilik/veri beyanı, yaş derecelendirmesi ve oyuncu destek bilgisi nihai sürümle aynıdır.

### 13.5 Son doğrulama kaydı (10 Ekim 2026)

- `flutter test --no-pub --reporter compact`: **163/163 test geçti.** Önceki kampanya dengesi, gerçek savaş hamleleriyle sözleşme tamamlama, kayıt kurtarma/FIFO eşzamanlılık, erişilebilirlik ve görsel varlık testleri korunuyor. Yeni zırh çizim testleri başlık/gövde/çizme yuvalarının dört kademesini, bilinmeyen kimlikleri, birleşik donanım görünüşünü ve BattlePage bağlantısını doğruluyor. Yeni glyph testleri 14 özel Canvas glifinin çizimini, boyutlandırma/tema/semantik davranışını ve GameHub gezinme etiketlerini doğruluyor. Yeni rakip atlas testleri #10–13 eşlemelerini, PNG çözümünü ve FighterArt çizimini doğruluyor.
- `dart analyze`: çıkış kodu 0; hata/uyarı yok, **29 bilgi düzeyi lint notu** var.
- `flutter build web --release --no-pub` başarılı; derleme 68,1 saniyede tamamlandı. 16 eşlenmiş ana kadro hareket atlası ve #10–13 dosyaları `build/web/assets/assets/art/characters/` altında doğrulandı.
- `tool/build_android.ps1 -Format apk` başarılı; Gradle release derlemesi 457,0 saniye sürdü. `build/app/outputs/flutter-apk/app-release.apk` **164.282.683 bayt (yaklaşık 156,7 MiB)** olarak üretildi. APK içinde #10–13 atlasları doğrulandı. Android SDK 36.0.0 `apksigner verify --verbose --print-certs` APK’yi v2 imzasıyla doğruladı; sertifika `Android Debug`, yani bu paket mağazaya gönderilecek nihai imzalı yayın paketi değildir.
- Kullanıcı **A — Kül Halkası** simge yönünü onayladı. Nihai SVG/1024 px master, Android yoğunluk ve uyarlanabilir/tek renkli ikon kaynakları ile 19 iOS AppIcon eşlemesi mevcut; tüm iOS eşlemeleri dosya/ölçü kontrolünden geçti ve 1024 px iOS ikonu master PNG ile aynı. iOS/Xcode çalışma zamanı doğrulaması bu Windows ortamında yapılamadı.
- Android `applicationId` hâlâ örnek `com.example.ash_circuit`, sürüm `1.0.0`/kod `1`; release APK `Android Debug` sertifikasıyla imzalıdır. Bu dosya mağazaya gönderilecek nihai imzalı yayın paketi değildir.
- `tool/build_android.ps1` ASCII adlı geçici kardeş dizinde derleyip çıktıyı projeye kopyalayarak AOT aracının Türkçe `ı` içeren proje yoluna erişim sorununu aşıyor; Android paketleri bu betikle üretilmelidir.
- Bu Windows ortamında `flutter devices` yalnız Windows, Chrome ve Edge gösteriyor; `adb devices -l` boş ve `xcodebuild` yok. Gerçek Android/iOS cihaz, iOS derlemesi, farklı ekran oranları, ses-haptik davranışı ve düşük seviye cihaz performansı doğrulanmadı.
- Bu doğrulama anında `rivalMotionAtlasAssetsByEncounter` 32 ana karşılaşmanın 16’sına (#1–13, #16, #24, #32) özel hareket atlası bağlıyor; #14–15, #17–23 ve #25–31 için 16 rig daha gerekiyor. Kuşanılan üç zırh yuvası savaşçı modelinde görünür; poz-özel kahraman eylem kareleri bu katmanlı görünüşle henüz kullanılmıyor. 14 özel UI glifi navigasyona ve seçili arayüz yuvalarına bağlandı; bütün durum/seyirci ikonları ve silah/arena başına VFX varyantları tamamlanmalı. Android/iOS ürün kimliği ve mağaza imzası, mağaza varlıkları, gizlilik/veri beyanı, yaş derecelendirmesi, destek kanalı ve gerçek cihaz QA’si de yayın kapıları olarak sürüyor.

### 13.6 Ek doğrulama kaydı (10 Ekim 2026)

- #14 Kızıl Ocak Şefi, #15 Kükürt Matronu, #17 Menzil Avcısı ve #18 Ayna Kılıç için dört özgün 1536×1024 RGBA hareket atlası üretildi. Her dosya 3×2 düzende altı adet 512×512 poz içerir ve üretilen kaynak master ile bayt bayt aynıdır. Hücre köşeleri alfa kontrolünden, görseller de manuel atlas incelemesinden geçti.
- `flutter test --no-pub --reporter compact test/next_rival_motion_assets_test.dart`: **2/2 test geçti.** Eşlemeler, PNG çözümü, FighterArt çizimi ve şeffaf hücre köşeleri denetlendi; #19 sonraki eşlenmemiş rakip olarak kaldı. Eski `test/rival_motion_assets_test.dart` içindeki #14 boş eşleme beklentisi yeni haritayla güncellendi.
- `rivalMotionAtlasAssetsByEncounter` artık 32 ana karşılaşmanın 20’sine (#1–18, #24, #32) özel atlas bağlıyor. #19–23 ve #25–31 için 12 rig daha gerekiyor.
- Harita/test güncellemesinden sonra `flutter test --no-pub --reporter compact`: **163/163 test geçti**; `dart analyze` çıkış kodu 0, 29 bilgi düzeyi lint notu. Release build bu atlas grubundan sonra henüz yeniden alınmadı.
- Poz-özel kahraman aksiyon kareleri katmanlı özelleştirme ve kuşanılan teçhizatla hâlâ birlikte kullanılmıyor. Mevcut varlıklar bu pozlarda teçhizatı doğru hizalamak için yeterli değil; poz-özel katmanlı karakter varlıkları gerekir. UI glyph kapsamı, silah/arena VFX varyantları ve önceki kayıttaki mağaza/yayın/cihaz QA kapıları da açık.

### 13.7 Ek doğrulama kaydı (10 Ekim 2026)

- #19 Gelgit Mührücüsü, #20 Fırtına Avcısı, #21 Rüzgâr Seyircisi ve #22 Kıyı Orakçısı için dört hareket atlası eklendi. 1536×1024 RGBA dosyalarının her biri 3×2 düzende altı 512×512 poza sahiptir; runtime dosyaları kaynak master’larıyla bayt bayt aynı, hücre köşelerindeki alfa değerleri 0–1 aralığında. Atlaslar ayrıca görsel olarak incelendi.
- `test/rival_motion_assets_test.dart` 19–22 eşlemelerini ve #23’ün henüz eşlenmediğini doğrulayacak şekilde güncellendi. İki odaklı test dosyası birlikte **4/4 test** geçti.
- #19–22 eklemesinden sonra `flutter test --no-pub --reporter compact`: **163/163 test geçti**. `dart format --output=none --set-exit-if-changed` üç değişen Dart dosyasında temiz; `dart analyze` çıkış kodu 0, 29 bilgi düzeyi lint notu.
- `rivalMotionAtlasAssetsByEncounter` şu anda 32 ana karşılaşmanın 24’üne (#1–22, #24, #32) atlas bağlıyor. #23 ve #25–31 için sekiz rig gerekiyor. Bu batch’ten sonra web/Android release build yeniden alınmadı.
- Katmanlı oyuncu görünüşü ve kuşanılan teçhizatın poz-özel aksiyon atlaslarıyla hizalanması, kalan UI glyph/VFX kapsamı ve Android/iOS yayın kimliği, imza, mağaza, gizlilik, yaş derecelendirmesi, destek kanalı ile gerçek cihaz QA kapıları hâlâ açık.

## 14. Riskler ve azaltma planı

| Risk | Etki | Azaltma |
|---|---|---|
| Referans formüllerinin tam bilinmemesi | Yanlış “bire bir” beklentisi ve denge varsayımı | Referans bilgisi ile yeni tasarım kararı ayrılır; oyun kendi formülleriyle dengelenir |
| Saldırı ve çeviklik özelliklerinin ayrımı | İsabet/kaçınma formülünde tek bir baskın özellik | Dört yapıda isabet, kaçınma, hasar ve savunma eşikleri ayrı simüle edilir; savaş kartlarında sonuç/olasılık önizlemesi vardır |
| Tam içerik kapsamı ve varlık üretimi | Takvim/bütçe aşımı | Kapsam başta 32 ana maç + 8 turnuva finali + 4 hikâye seçimi + 16 sözleşme + 8 oyun sonu aşaması olarak kilitlenir; her içerik kartına maliyet/bağımlılık yazılır; değişiklikler süre ve bütçe etkisiyle onaylanır |
| Ekonomide tek baskın yapı | Tekrarlı ve sığ oynanış | Dört yapı ve 16 ara seçim dizisiyle simülasyon, ilk deneme galibiyeti ve maç süresi izlemi |
| Mobil ekranda bilgi yığılması | Yanlış hamle ve okunabilirlik kaybı | Hamle alanı sabit; log/durumlar açılır; değerler çubukla birlikte sayı olarak da gösterilir |
| Varlık üretiminin yavaşlaması | İçerik tamamlanmasının gecikmesi | Ortak animasyon rig’leri, altı net arena kimliği, manifestte parça başı sahip/teslim tarihi ve içerik kilidinden önce haftalık üretim kontrolü |
| Menzilli silahın baskınlaşması veya gereksiz kalması | Yapı ve maç çeşitliliğinin bozulması | Ayrı yay yuvası, açık fişek bütçesi, menzil isabet katsayıları ve dört yapı üzerinde silah ailesi başına simülasyon |
| Sarf eşyalarının ilerleme için zorunlu hale gelmesi | Sikke ekonomisi ve yenilgi akışında çıkmaz | Kullanım başına sınır, sınırlı envanter, ilk yenilgi desteği ve sarf kullanmayan oyuncu simülasyonu |
| Görsel performans/bellek | Düşük cihazlarda kare düşüşü | Atlas/çözünürlük bütçesi, cihaz profili, efekt azaltma seçeneği |
| Save/ödül/ara seçim yarış durumu | Çift ödül veya bozuk kayıt | Tek kaynaklı repository, sürümlü kayıt, atomik maç sonucu/ödül/olay seçimi yazımı |
| Kopya algısı | Ürün kimliği ve yayın riski | Özgün ad, dünya, karakter, diyalog, sanat, ses ve kod; yalnızca genel tür döngüsü referans alınır |

## 15. Üretime başlamadan kilitlenecek kararlar

Bu belge tam ürün kapsamı için temel varsayımları sağlar. İlk üretim sprintinden önce aşağıdaki kararlar ürün sahibiyle kesinleştirilir; köşeli parantez içindekiler öneridir:

1. Ürün adı ve yazım dili [“Kül Çemberi” çalışma adı; Türkçe + İngilizce].
2. Hedef işletim sistemi sürüm tabanı ve düşük seviye test cihazları [Android + iOS; en az bir eski/orta seviye telefon].
3. Görsel konsept onayı [fırtınalı ada ligi, bazalt koylar, grafik 2D].
4. Yatay ekran desteği [ilk telefon UX’i portre; tablet uyarlaması].
5. Ücretlendirme ve gelir modeli [premium veya ücretsiz; savaş gücü satan mikro ödeme yok].
6. Bulut kayıt/hesap isteği [ilk sürüm çevrimdışı; ihtiyaç doğrulanırsa sonraki sürüm].
7. Tam oyun kapsamı ve içerik ekibi kapasitesi [32 ana maç, 8 turnuva finali, 4 ara seçim, 16 sözleşme, 8 oyun sonu karşılaşması, 6 arena; 6–8 kişilik ekipte yaklaşık 43 hafta temel takvim + %15 risk payı].
8. Yayın ülkeleri, yaş derecelendirmesi ve destek kanalı [TR/EN, Android+iOS; mağaza gereklilikleri ülkeye ve yayın tarihine göre doğrulanır].
9. Seyirci Notu kapsamı [üç açık koşul, yalnızca skor kaydı ve dört kozmetik arma; Sikke/XP veya savaş etkisi yok].

## 16. İlk üretim sprintinin yapılacakları

1. Bu belgedeki ürün, gelir, platform, kapsam, takvim ve görsel varsayımlarını karar kaydında kilitle.
2. 32 ana maç, 8 turnuva finali, 4 ara seçim, #4/#12/#20/#28 için 4 hikâye izi olayı, 16 sözleşme ve 8 oyun sonu karşılaşma kartının tümünü şablonla doldur; turnuva sırası, arena, kilit, başarısızlık/tekrar, kayıt anahtarları ve ödül bağımlılıklarını içerik haritasında göster.
3. XP/Sikke/eşya fiyatı/mağaza kataloğu için tam 20 seviye ve 32 maçlık ekonomi çalışma kitabı hazırla; dört yapı, 16 ara-seçim dizisi ve harcama profili simülasyonlarını ekle.
4. Savaş, düşman yapay zekâsı, durum etkileri, seviye/ustalık ve kampanya kayıt şemalarını üretim kabul ölçütleriyle tanımla.
5. Bütün ekranlar için kullanıcı akışını, final/epilog ve sözleşme akışları dahil, portre ve tablet wireframe’leriyle tamamla.
6. 32 ana rakip, 8 turnuva finali için giriş/faz/sonuç varlıkları, 4 ara seçim kartı, 16 sözleşme, 6 arena, dört silah ailesi, dört dükkân simgesi, dört Seyirci Notu arması, sarf kataloğu, animasyon, ses ve TR/EN metin için sahip/tarih/ölçü/format içeren asset manifesti çıkar.
7. Flutter görev listesini, veri şeması ve kabul ölçütleriyle bağla; aynı kapsamı ekonomi, sanat, anlatı, ses, yerelleştirme ve QA görevlerine böl.
8. Üretim sırasını bağımlılıklara göre planla ve her aşama için tamamlanmış ürün çıktısı ile ölçülebilir çıkış koşulu atayarak tam oyun üretimine başla.

## 17. Kaynaklar

- [CrazyGames — Swords and Sandals 2](https://www.crazygames.com/game/swords-and-sandals-2): Ruffle üzerinde sunulan masaüstü tarayıcı sürümü, temel oyun döngüsü, Fandom bağlantısı ve sayfanın 9–10 saatlik süre tahmini; tek başına başka Flash/Steam sürümleriyle build eşdeğerliği kanıtı değildir.
- [Swords and Sandals Wiki ana sayfası](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_Wiki): Kaynağın kullanıcı katkılı topluluk ansiklopedisi olduğuna dair kendi açıklaması. Fandom içerikleri özgün oyun içeriği, metin veya görsel olarak kopyalanmaz.
- [Wiki — Items](https://swordsandsandals.fandom.com/wiki/Items): Arama dizininde savaşta kullanılabilen iksir ve büyülerin Magicka düzeyine bağlı olduğuna dair özet. Koşulun tam kapsamı ve Classic build eşleşmesi doğrudan sayfadan doğrulanamadı; yalnızca uygunluk/UX ve QA soruları üretmek için kullanıldı.
- [Wiki — Emperor’s Reign](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_2%3A_Emperor%27s_Reign), [Arena Bosses](https://swordsandsandals.fandom.com/wiki/Arena_Bosses), [Marksman Dantus](https://swordsandsandals.fandom.com/wiki/Marksman_Dantus), [Wizard Sagan](https://swordsandsandals.fandom.com/wiki/Wizard_Sagan), [The Great Beast](https://swordsandsandals.fandom.com/wiki/The_Great_Beast), [Spheracles](https://swordsandsandals.fandom.com/wiki/Spheracles), [The Slave Driver](https://swordsandsandals.fandom.com/wiki/The_Slave_Driver), [Gaiax](https://swordsandsandals.fandom.com/wiki/Gaiax), [Daimyo Katsumodo](https://swordsandsandals.fandom.com/wiki/Daimyo_Katsumodo), [HeChaos](https://swordsandsandals.fandom.com/wiki/HeChaos_the_Scourge), [Zeerzabahl](https://swordsandsandals.fandom.com/wiki/Archfiend_Zeerzabahl), [Sandalphon](https://swordsandsandals.fandom.com/wiki/Archangel_Sandalphon), [Nameless Shadow](https://swordsandsandals.fandom.com/wiki/The_Nameless_Shadow) ve [Emperor Antares](https://swordsandsandals.fandom.com/wiki/Emperor_Antares): Classic karşılaşma sırası ve rol/teçhizat profilleri için topluluk kaynağı. Sıralama ve istatistikler oynanışta ayrıca doğrulanmamıştır; yalnızca seviye ritmi ve rakip profili kontrol listesi olarak kullanılmıştır.
- [Wiki — S&S II Weapons](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_II_Weapons), [Emperor’s Reign](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_2%3A_Emperor%27s_Reign) ve [S&S II Bugs](https://swordsandsandals.fandom.com/wiki/Swords_and_Sandals_II_Bugs): Silah özellik koşulları, kısmi fiyat/enchant/fişek tabloları ve sürümlere göre bildirilen hata sınıfları. Rakamlar doğrulanmış veri değildir; yeni oyun için kod, ekonomi ve QA gereksinimi olarak uyarlanırken kaynak belirsizliği korunur.
- [Wiki — Quests](https://swordsandsandals.fandom.com/wiki/Quests) ve [Charisma](https://swords-and-sandals.fandom.com/wiki/Charisma): Düello arası seçimlerin stat/kaynak etkisi ve Charisma’nın tribün, taunt, ödül, tüccar fiyatı iddiaları için ikincil keşif kaynağı; Classic build’de doğrulanmış mekanik kabul edilmez.
- [Flash Gaming Wiki — Swords and Sandals 2](https://flashgaming.fandom.com/wiki/Swords_And_Sandals_2): Topluluk sayfası; karakter yaratma/ilk düello, dört hizmet türü, seviye ile turnuva/ödül ilerlemesi, yedi giyilebilir zırh parçası ve ayrı kalkan kayıtları. Miğfer örneklerinde 1.200 altından seviye 48’de 187.500 altına uzanan fiyat eğrisi listelenir. Zırh sayımının “sekiz” olarak aktarılması kalkanı ek savunma konumu saymaktan kaynaklanabilir; wiki terimleri ve build doğrulaması kesin değildir. 77 silah sayımı ve tablolar sürüm/katalog kapsamı ile doğruluk açısından teyitsizdir; mekanik keşfi için kullanılmış, yeni oyun formülü veya içerik kotası sayılmamıştır.
- [Swords and Sandals — resmi Tome of Lore](https://swordsandsandals.com/) ve [Classic Collection tanıtımı](https://swordsandsandals.com/swords-and-sandals-classic-collection/): Geliştiricinin Tome’u Doomtrek’te altı yeni arena ve “20 notable Arena Champions” der; aynı listede 22 karakter maddesi görünür. Tutorial’daki Fearful Prisoner ve bilerek kaybeden Bhaargle cameo’su istisna sayılırsa 20’ye ulaşılması araştırmacı çıkarımıdır, açıkça belirtilmiş roster tanımı değildir. Tome, Sir Belgrave’in Classic’te dövüşülen ama Redux’ta NPC olan karakter olduğunu açıklar. Fandom’ın 18 maddelik Classic boss sırası da arama dizinindeki topluluk iddiasıdır ve oynanışta doğrulanmamıştır. Kaynaklar aynı karşılaşma sayısını ölçtüğünü kanıtlamaz; plan yeni oyuna 18, 20 veya 22 rakip kotası koymaz.
- [Newgrounds — Swords and Sandals 2 yapımcı notu](https://www.newgrounds.com/portal/view/358324): Yapımcının tanıtım build’i notu; turnuva, menzilli silah, büyü ve şampiyon yenilikleri ile demo sürüm sınırı.
- [Steam — Swords and Sandals 2 Redux](https://store.steampowered.com/app/649600/Swords_and_Sandals_2_Redux/) ve [Google Play — Swords and Sandals 2 Redux](https://play.google.com/store/apps/details?id=air.com.game.whiskeybarrelstudios.swordsandsandals2): Yayımcı mağaza sayfaları; yalnızca Redux sürümünün özellik ve içerik sayılarını doğrulamak için. [Steam geliştirici duyurusu](https://store.steampowered.com/news/app/649600/view/4738306083312209369), Redux içindeki Classic Edition seçeneğinin ek turnuva/denge düzenlemeleriyle aynı Redux uygulamasına ait olduğunu açıklar; özgün Flash build’iyle eşdeğerlik varsayılmaz.
- [Steam — Swords and Sandals Classic Collection](https://store.steampowered.com/app/1055430/Swords_and_Sandals_Classic_Collection/): Seri koleksiyonu tanıtımı; “yirmi efsanevi dövüşçü” ifadesi kesin S&S II karşılaşma sırası veya roster dökümü olarak kullanılmamıştır.
- [Flutter — Guide to app architecture](https://docs.flutter.dev/app-architecture/guide): UI/veri katmanı, View/ViewModel/Repository/Service sorumlulukları.
- [Flame — Overlays](https://docs.flame-engine.org/latest/flame/overlays.html): Tam savaş sahnesi Flame gerektirirse Flutter widget’larını oyun yüzeyinde kullanma olanağı.
- [Android — Accessible touch targets](https://developer.android.com/guide/topics/ui/accessibility/views/apps-views) ve [Apple — Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons): Dokunma hedefleri ve basılma durumları.
- [W3C — WCAG 2.2 Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum): Metin kontrastı kabul ölçütleri.

