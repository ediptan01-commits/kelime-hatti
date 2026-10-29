part of 'main.dart';

class CaseLevel extends Level {
  final String caller;
  final String message;
  final String evidence;
  final String fact;
  final String source;
  final String? sourceUrl;
  final List<String> hints;
  const CaseLevel(
      super.name, super.clue, super.answer, super.story, super.incomingClue,
      {required this.caller,
      required this.message,
      required this.evidence,
      required this.fact,
      this.source = 'Kavram notu',
      this.sourceUrl,
      required this.hints});
}

const _caseArchive = <CaseLevel>[
  CaseLevel(
      'Gece Gelen Hat',
      'Eski belgelerin düzenlenip korunduğu yer. İlk iz burada saklı.',
      'ARŞİV',
      'İdil sana 17 numaralı çekmecenin fişini gönderdi. Fişte saatin fotoğrafı ve “Kayıt 42” yazıyor.',
      '42 numaralı kaydı bulmalısın.',
      caller: 'İdil · Müze görevlisi',
      message:
          'Müzedeki cep saati vitrinde yok. Herkes çalındığını söylüyor. Gece telefonun çalarsa şaşırma; bu hattı yalnızca sana verdim. Önce eski belgelerin tutulduğu yere bak.',
      evidence: '17 numaralı çekmece fişi',
      fact:
          'Arşiv belgelerini düzenli kayıtlarla korumak, geçmişteki bir olayı farklı belgeleri karşılaştırarak araştırmayı mümkün kılar.',
      source: 'Devlet Arşivleri · Belge araştırması',
      sourceUrl: 'https://katalog.devletarsivleri.gov.tr/',
      hints: [
        'Belgeler burada saklanır ve araştırılır.',
        'Kelime A harfiyle başlıyor.',
        'İlk iki harf: AR'
      ]),
  CaseLevel(
      'Kırk İki Numaralı Kayıt',
      'Müzedeki eserlerin kimlik ve kayıt listesinin adı nedir?',
      'ENVANTER',
      'Kayıt 42’de saatin müzeye kalıcı olarak verilmediği yazıyor. Bir sonraki satır ise kâğıtla kapatılmış.',
      'Kâğıdı ışığa tut.',
      caller: 'İdil · Müze görevlisi',
      message:
          'Çekmece fişindeki 42 sayısı eser numarasıymış. Fotoğraflar, ölçüler ve geliş tarihleri aynı defterde. Bu kayıt sisteminin adını bulursan doğru sayfaya ulaşırız.',
      evidence: '42 numaralı eser sayfası',
      fact:
          'Müzelerde eserler envanter kayıtlarıyla takip edilir. Bu kayıtlar eserin kimliği ve müzeye gelişi gibi bilgileri bir arada tutar.',
      source: 'Kültür ve Turizm Bakanlığı · Müzecilik Kılavuzu',
      sourceUrl: 'https://teftis.ktb.gov.tr/TR-13998/muzecilik-klavuzu.html',
      hints: [
        'Bir kurumun elindeki varlıkların kayıt listesi.',
        'Kelime E harfiyle başlıyor.',
        'İlk üç harf: ENV'
      ]),
  CaseLevel(
      'Işıkta Görünen İz',
      'Kâğıt ışığa tutulunca görünen, yapısındaki desenin adı.',
      'FİLİGRAN',
      'Kâğıtta yıldız biçimli bir iz belirdi. Aynı kâğıttan yapılmış bir zarf, mühürlü izin belgesinin yanında duruyor.',
      'Zarfın üzerindeki damgayı incele.',
      caller: 'Nermin · Kâğıt uzmanı',
      message:
          'Bu notun yüzeyinde mürekkep yok. Işığın karşısına tutunca yıldız görünüyor. Böyle bir iz tek başına belgenin yaşını kanıtlamaz; ama iki kâğıdı karşılaştırmamıza yardım eder.',
      evidence: 'Yıldız desenli kâğıt',
      fact:
          'Filigran ışığa tutulunca görülebilen bir kâğıt özelliğidir. Banknotlarda da kullanılır; bir banknotu kontrol ederken tek bir güvenlik özelliğine güvenilmez.',
      source: 'TCMB · Banknot güvenlik özellikleri',
      sourceUrl: 'https://www3.tcmb.gov.tr/tlkampanya/download/TLbrosur.pdf',
      hints: [
        'Banknotların güvenlik özelliklerinden de biridir.',
        'Kelime F harfiyle başlıyor.',
        'İlk üç harf: FİL'
      ]),
  CaseLevel(
      'Kapalı Zarf',
      'Bir belgeye damga basmak için kullanılan araç.',
      'MÜHÜR',
      'Zarfın içindeki izin belgesinde “12 Kasım, 09.00: atölyeye sevk uygundur” yazıyor. Üstte bir isim var: Leyla.',
      'Leyla’nın gönderdiği mesajı bul.',
      caller: 'İdil · Müze görevlisi',
      message: 'Zarfı açtık. Belgenin altında kabartmalı bir damga var. Bu araç belgeye bir işaret basar; fakat damganın bulunması tek başına bütün hikâyeyi açıklamaz. Tarih ve imzayı da sakla.',
      evidence: '12 Kasım tarihli sevk izni',
      fact: 'Mühür bir işareti yüzeye basmaya yarayan araçtır. Bir belgeyi değerlendirirken işaret, imza, tarih ve diğer kayıtlar birlikte incelenir.',
      hints: [
        'Belgeye damga basar.',
        'Kelime M harfiyle başlıyor.',
        'İlk iki harf: MÜ'
      ]),
  CaseLevel(
      'Uzak İstasyon',
      'Elektrik sinyalleriyle uzaktaki bir yere yazılı haber ileten tarihî sistem.',
      'TELGRAF',
      'Leyla’nın istasyon mesajı bulundu: “Saat 10.00’da ustaya teslim edildi.” Mesajın ekinde nokta ve çizgiler var.',
      'Kısa ve uzun işaretlerin dilini çöz.',
      caller: 'Cem · İstasyon arşivi',
      message:
          'Leyla şehir dışındaymış. İzni verdikten sonra istasyondan kısa bir haber göndermiş. Telefon konuşması değil; uzaktaki görevliye yazılı olarak ulaşan eski bir haberleşme yöntemi.',
      evidence: 'İstasyon mesajının kopyası',
      fact:
          'Telgraf, haberleri elektrik sinyalleriyle ileten haberleşme sistemlerinin genel adıdır. Tarihsel telgraf sistemlerinde farklı kodlama yöntemleri kullanılmıştır.',
      hints: [
        'Telefon öncesi haberleşme yöntemlerinden biridir.',
        'Kelime T harfiyle başlıyor.',
        'İlk üç harf: TEL'
      ]),
  CaseLevel(
      'Nokta ve Çizgi',
      'Harfleri kısa ve uzun işaretlerle gösteren kodun kısa adı.',
      'MORS',
      'Ek mesaj “SATIŞ YOK” diyor. Ama çekmecede fiyatların yazılı olduğu başka bir kâğıt var. İkisi neden çelişiyor?',
      'Fiyat kâğıdı bir satış belgesi olmayabilir.',
      caller: 'Cem · İstasyon arşivi',
      message:
          'Ek kâğıttaki kısa ve uzun işaretleri tanıdım. Örneğin S üç nokta, O üç çizgidir. Kodu bulduğunda mesajın metnini sana aktaracağım.',
      evidence: '“Satış yok” mesajı',
      fact:
          'Uluslararası Mors kodunda harfler kısa ve uzun işaretlerle gösterilir. S “···”, O “−−−” biçimindedir.',
      source: 'ITU · Uluslararası Mors kodu',
      sourceUrl: 'https://www.itu.int/rec/R-REC-M.1677-1-200910-I/en',
      hints: [
        'Nokta ve çizgilerden oluşur.',
        'Kelime M harfiyle başlıyor.',
        'İlk iki harf: MO'
      ]),
  CaseLevel(
      'İmzalanmamış Teklif',
      'Para kullanmadan, bir malı başka bir malla değiştirme.',
      'TAKAS',
      'Kâğıt bir değişim teklifiymiş. Üstündeki “KABUL EDİLMEDİ” notu ve imza boşluğu, saatin el değiştirdiğini göstermiyor.',
      'Bir teklif ile gerçekleşmiş işlem aynı şey değildir.',
      caller: 'Leyla · Saatin sahibi',
      message:
          'Bir koleksiyoncu saatime karşılık başka bir eşya önerdi. Kabul etmedim. Sadece bir taslak bıraktı. O kâğıdı gören herkes saatin satıldığını düşünmüş olabilir.',
      evidence: 'Reddedilmiş değişim teklifi',
      fact:
          'Takas, para kullanılmadan mal veya hizmet değişimidir. Bir teklifin yazılmış olması, değişimin gerçekleştiği anlamına gelmez.',
      hints: [
        'Bir şeyi para yerine başka bir şeyle değiştirmek.',
        'Kelime T harfiyle başlıyor.',
        'İlk iki harf: TA'
      ]),
  CaseLevel(
      'Fiyatların Yazdığı Sayfa',
      'Belirli bir dönem için beklenen gelir ve gider planı.',
      'BÜTÇE',
      'Fiyat sayfası satış hesabı değil, atölye için hazırlanmış harcama planı. “Parça ve işçilik” satırının yanında eski bir fiyat notu var.',
      'Tek bir fiyat değişikliğini bütün ekonomiyle karıştırma.',
      caller: 'Mahir · Saat ustası',
      message:
          'O rakamlar saatin fiyatı değil. Yapılacak işin giderlerini ve ayrılan parayı yazmıştım. Belirli bir süre için gelirle gideri karşılaştıran bu planın adını bul.',
      evidence: 'Atölyenin harcama planı',
      fact:
          'Bütçe, belirli bir dönem için öngörülen gelir ve giderlerin planıdır. Yazılan bir tahmin ile gerçekleşen harcama birbirinden farklıdır.',
      source: 'MEB · Bireysel bütçeleme',
      sourceUrl:
          'https://meslek.meb.gov.tr/upload/dersmateryali/pdf/MF2024FOK111202.pdf',
      hints: [
        'Aileler, kurumlar ve devletler de hazırlar.',
        'Kelime B harfiyle başlıyor.',
        'İlk iki harf: BÜ'
      ]),
  CaseLevel(
      'Tek Fiyat Yetmez',
      'Tek bir ürünün değil, genel fiyat düzeyinin sürekli yükselmesi.',
      'ENFLASYON',
      'Usta “Parça pahalandı diye saatin satıldığını sanmayın” diyor. Gider planının arkasında iş emrinin numarası çıktı.',
      'İş emrinin ne için düzenlendiğini bul.',
      caller: 'Mahir · Saat ustası',
      message:
          'Geçen yıl bir parça daha ucuzdu. Ama tek parçanın pahalanması genel bir fiyat artışını tek başına kanıtlamaz. Çok sayıda mal ve hizmetin genel fiyat düzeyindeki sürekli artışına ne denir?',
      evidence: 'Eski ve yeni parça fiyatı notu',
      fact:
          'Enflasyon genel fiyat düzeyinin sürekli artmasıdır; tek bir ürünün pahalanmasıyla aynı şey değildir. Enflasyonun yavaşlaması da fiyatların mutlaka düştüğü anlamına gelmez.',
      source: 'TCMB · Enflasyon ve Para Politikası',
      sourceUrl:
          'https://www.tcmb.gov.tr/wps/wcm/connect/2d9f2c1d-18eb-4124-8fd9-a4ea189a24ad/100soruweb1.pdf?MOD=AJPERES',
      hints: [
        'Paranın satın alma gücüyle ilgilidir.',
        'Kelime E harfiyle başlıyor.',
        'İlk üç harf: ENF'
      ]),
  CaseLevel(
      'Ustanın Tezgâhı',
      'Bozulan bir eşyayı yeniden çalışır duruma getirme işi.',
      'ONARIM',
      'İş emrinde saatin seri numarası var: 42. “10.00 teslim, yay değişimi” yazıyor. Saat, ustanın kilitli dolabında.',
      'Saatin kim adına tutulduğunu gösteren son belgeyi iste.',
      caller: 'Mahir · Saat ustası',
      message:
          'Saatin yayı kırılmıştı. Yeniden çalışır hâle getirmek için teslim aldım. Belgedeki numarayı müze kaydıyla karşılaştır: ikisinde de 42 var.',
      evidence: '42 numaralı iş emri',
      fact:
          'Onarım, bozulan bir eşyanın işlevini yeniden kazanması için yapılan çalışmadır. Müze eserlerindeki koruma uygulamaları ise ayrıca uzmanlık gerektirir.',
      hints: [
        'Tamir sözcüğüyle yakın anlamlıdır.',
        'Kelime O harfiyle başlıyor.',
        'İlk iki harf: ON'
      ]),
  CaseLevel(
      'İade Edilecek Eşya',
      'Sahibine geri verilmek üzere birine bırakılan şey.',
      'EMANET',
      'Makbuzda “Leyla adına, onarım sonrası iade edilecek” yazıyor. Saatin sahibi değişmemiş. Müzedeki yeni deftere bu not aktarılmamış.',
      'Artık belgeleri tarih ve saatlerine göre sırala.',
      caller: 'Leyla · Saatin sahibi',
      message:
          'Saatimi bağışlamadım ve satmadım. Sergi için geçici olarak bırakmıştım. Ustanın makbuzunda da bana geri verileceği yazıyor. Bu durumu tek kelimeyle nasıl anlatırsın?',
      evidence: 'Leyla adına iade makbuzu',
      fact:
          'Günlük dilde emanet, korunup sahibine geri verilmek üzere bırakılan şeyi anlatır. Buradaki hikâye kurgusaldır; belge ayrıntıları gerçek bir olaya ait değildir.',
      hints: [
        'Korunmak üzere bırakılır, sonra sahibine verilir.',
        'Kelime E harfiyle başlıyor.',
        'İlk iki harf: EM'
      ]),
  CaseLevel(
      'Son Bağlantı',
      'Olayları gerçekleşme zamanlarına göre sıralama.',
      'KRONOLOJİ',
      '09.00 sevk izni → 10.00 atölyeye teslim → 10.15 istasyon mesajı. Yeni defterde yalnızca eksik bir aktarım var. Son karar senin.',
      'Kanıtları birleştir ve dosyayı sonuçlandır.',
      caller: 'İdil · Müze görevlisi',
      message:
          'İzin belgesini, ustanın makbuzunu ve istasyon mesajını yan yana koydum. Şimdi onları gerçekleşme zamanlarına göre düzenlemeliyiz. Bu yöntemin adını bul; sonra son kararını ver.',
      evidence: 'Tamamlanmış olay çizelgesi',
      fact:
          'Kronoloji, olayları zaman sırasıyla ele alır. Bir iddiayı değerlendirirken belgelerin tarihlerini karşılaştırmak çelişkileri fark etmeye yardım eder.',
      hints: [
        'Tarih ve saat sırasını esas alır.',
        'Kelime K harfiyle başlıyor.',
        'İlk üç harf: KRO'
      ]),
];

// Fast play: a short riddle, a short answer, then one line of mystery.
const _quickPuzzles = <(String, String, String, String)>[
  (
    'SAAT',
    'Akrep ve yelkovanım var. Yürürüm ama yerimden gitmem.',
    'Vitrin boş. Çekmecede bir iz var.',
    'Zamanı gösteren eşya.'
  ),
  (
    'ZARF',
    'Mektubu saklarım, üstümde pul taşırım. Neyim?',
    'Zarftaki 42 sayısı neyi gizliyor?',
    'Kâğıttan yapılan mektup kabı.'
  ),
  (
    'IŞIK',
    'Karanlık odayı görünür yapan şey nedir?',
    'Kâğıtta gizli bir yıldız belirdi.',
    'Görmek için gözümüze ulaşması gerekir.'
  ),
  (
    'İZİN',
    '“Saati götürebilirsiniz.” Bu söz bir ... verir.',
    '09.00: Saati götürmeye onay var.',
    'Bir şeyi yapmana onay verilmesi.'
  ),
  (
    'HAT',
    'İki telefonu birbirine bağlayan bağlantı.',
    'İstasyondan gizli bir mesaj geldi.',
    'Telefon ... çekmiyor deriz.'
  ),
  (
    'MORS',
    'Nokta + çizgi = hangi haberleşme kodu?',
    'Mesaj: SATIŞ YOK. Peki fiyatlar?',
    'S üç nokta, O üç çizgidir.'
  ),
  (
    'TAKAS',
    'Para yok! Bir eşya ver, başka bir eşya al.',
    'Teklif var. Ama imza neden yok?',
    'Para kullanmadan değişim yapmak.'
  ),
  (
    'BÜTÇE',
    'Gelir 100, gider 80. Bu para planının adı ne?',
    'Rakamlar satış değil, gider planı.',
    'Gelir ve giderleri planlar.'
  ),
  (
    'ZAM',
    'Dün 10, bugün 12 lira. Fiyata ne gelmiş?',
    'Pahalanan saat değil, bir parça!',
    'Bir fiyatın yükselmesi.'
  ),
  (
    'YAY',
    'Sıkışırım, bırakınca açılırım. Saatin içinde de varım.',
    'Kırık parça bulundu. Saat ustada!',
    'Esnek, kıvrılmış bir metal parça.'
  ),
  (
    'İSİM',
    'Saatin sahibi Leyla. “Leyla” onun neyi?',
    'Makbuzda Leyla yazıyor. İade var.',
    'Sana nasıl sesleneceğimizi söyler.'
  ),
  (
    'SIRA',
    '09.00 → 10.00 → 10.15. Olayları zaman ...sına koy.',
    'Bütün izler birleşti. Son karar!',
    'Önce ne oldu, sonra ne oldu?'
  ),
];

final caseLevels =
    List<CaseLevel>.unmodifiable(List.generate(_caseArchive.length, (i) {
  final old = _caseArchive[i];
  final quick = _quickPuzzles[i];
  return CaseLevel(old.name, quick.$2, quick.$1, old.story, quick.$3,
      caller: old.caller,
      message: quick.$3,
      evidence: old.evidence,
      fact: old.fact,
      source: old.source,
      sourceUrl: old.sourceUrl,
      hints: [
        quick.$4,
        'İlk harf: ${quick.$1[0]}',
        'Başlangıç: ${quick.$1.substring(0, 2)}'
      ]);
}));


final _newCaseLevels = <CaseLevel>[
  CaseLevel('Son Bilet', 'Trene binmek için alınan yolculuk belgesi.', 'BİLET', 'Biletin arkasında gece yarısı yazıyor.', 'Biletin arkasında gece yarısı yazıyor.', caller: 'Gizemli hat', message: 'Biletin arkasında gece yarısı yazıyor.', evidence: 'Son Bilet · bulunan iz', fact: 'Trene binmek için alınan yolculuk belgesi.', hints: ['Trene binmek için alınan yolculuk belgesi.', 'İlk harf: B', 'Başlangıç: Bİ']),
  CaseLevel('Kayıp Yolcu', 'Bir araçla seyahat eden kişi.', 'YOLCU', 'Listede bir kişinin adı silinmiş.', 'Listede bir kişinin adı silinmiş.', caller: 'Gizemli hat', message: 'Listede bir kişinin adı silinmiş.', evidence: 'Kayıp Yolcu · bulunan iz', fact: 'Bir araçla seyahat eden kişi.', hints: ['Bir araçla seyahat eden kişi.', 'İlk harf: Y', 'Başlangıç: YO']),
  CaseLevel('Karanlık Peron', 'İstasyonda trene binilen platform.', 'PERON', 'Üç numaralı platformda bir valiz var.', 'Üç numaralı platformda bir valiz var.', caller: 'Gizemli hat', message: 'Üç numaralı platformda bir valiz var.', evidence: 'Karanlık Peron · bulunan iz', fact: 'İstasyonda trene binilen platform.', hints: ['İstasyonda trene binilen platform.', 'İlk harf: P', 'Başlangıç: PE']),
  CaseLevel('Eski Valiz', 'Yolculukta eşyaları taşıyan saplı büyük çanta.', 'VALİZ', 'Çantanın içinde kilitli bir bölme var.', 'Çantanın içinde kilitli bir bölme var.', caller: 'Gizemli hat', message: 'Çantanın içinde kilitli bir bölme var.', evidence: 'Eski Valiz · bulunan iz', fact: 'Yolculukta eşyaları taşıyan saplı büyük çanta.', hints: ['Yolculukta eşyaları taşıyan saplı büyük çanta.', 'İlk harf: V', 'Başlangıç: VA']),
  CaseLevel('Gizli Bölme', 'Anahtarla açılan kapatma düzeneği.', 'KİLİT', 'Bölme açıldı; altıncı vagonun planı çıktı.', 'Bölme açıldı; altıncı vagonun planı çıktı.', caller: 'Gizemli hat', message: 'Bölme açıldı; altıncı vagonun planı çıktı.', evidence: 'Gizli Bölme · bulunan iz', fact: 'Anahtarla açılan kapatma düzeneği.', hints: ['Anahtarla açılan kapatma düzeneği.', 'İlk harf: K', 'Başlangıç: Kİ']),
  CaseLevel('Sessiz Vagon', 'Trenin yolcu veya yük taşıyan bölümü.', 'VAGON', 'Boş koltukta kırık bir pusula duruyor.', 'Boş koltukta kırık bir pusula duruyor.', caller: 'Gizemli hat', message: 'Boş koltukta kırık bir pusula duruyor.', evidence: 'Sessiz Vagon · bulunan iz', fact: 'Trenin yolcu veya yük taşıyan bölümü.', hints: ['Trenin yolcu veya yük taşıyan bölümü.', 'İlk harf: V', 'Başlangıç: VA']),
  CaseLevel('Kırık Pusula', 'İğnesi kuzeyi gösteren yön bulma aracı.', 'PUSULA', 'İğnenin altındaki işaret son durağı gösteriyor.', 'İğnenin altındaki işaret son durağı gösteriyor.', caller: 'Gizemli hat', message: 'İğnenin altındaki işaret son durağı gösteriyor.', evidence: 'Kırık Pusula · bulunan iz', fact: 'İğnesi kuzeyi gösteren yön bulma aracı.', hints: ['İğnesi kuzeyi gösteren yön bulma aracı.', 'İlk harf: P', 'Başlangıç: PU']),
  CaseLevel('Son İstasyon', 'Bir taşıtın yolcu almak için durduğu yer.', 'DURAK', 'Eski bekleme odasında bir kart bulundu.', 'Eski bekleme odasında bir kart bulundu.', caller: 'Gizemli hat', message: 'Eski bekleme odasında bir kart bulundu.', evidence: 'Son İstasyon · bulunan iz', fact: 'Bir taşıtın yolcu almak için durduğu yer.', hints: ['Bir taşıtın yolcu almak için durduğu yer.', 'İlk harf: D', 'Başlangıç: DU']),
  CaseLevel('Kimliği Belirsiz', 'Bir kişinin kim olduğunu gösteren belge.', 'KİMLİK', 'Kart tren görevlisine ait; yanında yarım mesaj var.', 'Kart tren görevlisine ait; yanında yarım mesaj var.', caller: 'Gizemli hat', message: 'Kart tren görevlisine ait; yanında yarım mesaj var.', evidence: 'Kimliği Belirsiz · bulunan iz', fact: 'Bir kişinin kim olduğunu gösteren belge.', hints: ['Bir kişinin kim olduğunu gösteren belge.', 'İlk harf: K', 'Başlangıç: Kİ']),
  CaseLevel('Yarım Kalmış Mesaj', 'Elektrik sinyalleriyle yazılı haber ileten eski sistem.', 'TELGRAF', 'Mesajda yolun kapandığı ve gizli geçit yazıyor.', 'Mesajda yolun kapandığı ve gizli geçit yazıyor.', caller: 'Gizemli hat', message: 'Mesajda yolun kapandığı ve gizli geçit yazıyor.', evidence: 'Yarım Kalmış Mesaj · bulunan iz', fact: 'Elektrik sinyalleriyle yazılı haber ileten eski sistem.', hints: ['Elektrik sinyalleriyle yazılı haber ileten eski sistem.', 'İlk harf: T', 'Başlangıç: TE']),
  CaseLevel('Saklı Geçit', 'Dağın veya yerin içinden geçen kapalı yol.', 'TÜNEL', 'Tren burada saklanmış; sürücünün defteri bulundu.', 'Tren burada saklanmış; sürücünün defteri bulundu.', caller: 'Gizemli hat', message: 'Tren burada saklanmış; sürücünün defteri bulundu.', evidence: 'Saklı Geçit · bulunan iz', fact: 'Dağın veya yerin içinden geçen kapalı yol.', hints: ['Dağın veya yerin içinden geçen kapalı yol.', 'İlk harf: T', 'Başlangıç: TÜ']),
  CaseLevel('Son Yolculuk', 'Treni kullanan görevli.', 'MAKİNİST', 'Sürücü herkesi kurtarmak için treni yan hatta almış.', 'Sürücü herkesi kurtarmak için treni yan hatta almış.', caller: 'Gizemli hat', message: 'Sürücü herkesi kurtarmak için treni yan hatta almış.', evidence: 'Son Yolculuk · bulunan iz', fact: 'Treni kullanan görevli.', hints: ['Treni kullanan görevli.', 'İlk harf: M', 'Başlangıç: MA']),
  CaseLevel('Bilinmeyen Numara', 'Telefon aramak için çevrilen rakam dizisi.', 'NUMARA', 'Gizemli aramalar aynı hattan geliyor.', 'Gizemli aramalar aynı hattan geliyor.', caller: 'Gizemli hat', message: 'Gizemli aramalar aynı hattan geliyor.', evidence: 'Bilinmeyen Numara · bulunan iz', fact: 'Telefon aramak için çevrilen rakam dizisi.', hints: ['Telefon aramak için çevrilen rakam dizisi.', 'İlk harf: N', 'Başlangıç: NU']),
  CaseLevel('Eski Santral', 'Telefon hatlarının birbirine bağlandığı merkez.', 'SANTRAL', 'Aramaların kaynağı terk edilmiş bağlantı merkezi.', 'Aramaların kaynağı terk edilmiş bağlantı merkezi.', caller: 'Gizemli hat', message: 'Aramaların kaynağı terk edilmiş bağlantı merkezi.', evidence: 'Eski Santral · bulunan iz', fact: 'Telefon hatlarının birbirine bağlandığı merkez.', hints: ['Telefon hatlarının birbirine bağlandığı merkez.', 'İlk harf: S', 'Başlangıç: SA']),
  CaseLevel('Kayıp Sinyal', 'Bilgi taşıyan elektriksel işaret.', 'SİNYAL', 'Zayıf işaret bodrumdaki cihazdan geliyor.', 'Zayıf işaret bodrumdaki cihazdan geliyor.', caller: 'Gizemli hat', message: 'Zayıf işaret bodrumdaki cihazdan geliyor.', evidence: 'Kayıp Sinyal · bulunan iz', fact: 'Bilgi taşıyan elektriksel işaret.', hints: ['Bilgi taşıyan elektriksel işaret.', 'İlk harf: S', 'Başlangıç: Sİ']),
  CaseLevel('Şifreli Kayıt', 'Bir sesin sonradan dinlemek için saklanmış hâli.', 'KAYIT', 'Bantta trenin yardım çağrısı duyuluyor.', 'Bantta trenin yardım çağrısı duyuluyor.', caller: 'Gizemli hat', message: 'Bantta trenin yardım çağrısı duyuluyor.', evidence: 'Şifreli Kayıt · bulunan iz', fact: 'Bir sesin sonradan dinlemek için saklanmış hâli.', hints: ['Bir sesin sonradan dinlemek için saklanmış hâli.', 'İlk harf: K', 'Başlangıç: KA']),
  CaseLevel('Gizli Hat', 'Elektriği veya sinyali ileten yalıtılmış tel.', 'KABLO', 'Duvarın arkasındaki tel nöbet odasına gidiyor.', 'Duvarın arkasındaki tel nöbet odasına gidiyor.', caller: 'Gizemli hat', message: 'Duvarın arkasındaki tel nöbet odasına gidiyor.', evidence: 'Gizli Hat · bulunan iz', fact: 'Elektriği veya sinyali ileten yalıtılmış tel.', hints: ['Elektriği veya sinyali ileten yalıtılmış tel.', 'İlk harf: K', 'Başlangıç: KA']),
  CaseLevel('Gece Nöbeti', 'Belirli bir süre görev başında bekleme işi.', 'NÖBET', 'O gece görevli olan kişinin adı defterde.', 'O gece görevli olan kişinin adı defterde.', caller: 'Gizemli hat', message: 'O gece görevli olan kişinin adı defterde.', evidence: 'Gece Nöbeti · bulunan iz', fact: 'Belirli bir süre görev başında bekleme işi.', hints: ['Belirli bir süre görev başında bekleme işi.', 'İlk harf: N', 'Başlangıç: NÖ']),
  CaseLevel('Kesilen Ses', 'İletişimde duyulan istenmeyen cızırtı.', 'PARAZİT', 'Cızırtı temizlenince bir frekans duyuluyor.', 'Cızırtı temizlenince bir frekans duyuluyor.', caller: 'Gizemli hat', message: 'Cızırtı temizlenince bir frekans duyuluyor.', evidence: 'Kesilen Ses · bulunan iz', fact: 'İletişimde duyulan istenmeyen cızırtı.', hints: ['İletişimde duyulan istenmeyen cızırtı.', 'İlk harf: P', 'Başlangıç: PA']),
  CaseLevel('Eski Frekans', 'Bir dalganın saniyedeki titreşim sayısı.', 'FREKANS', 'Doğru ayar gizli odanın yerini veriyor.', 'Doğru ayar gizli odanın yerini veriyor.', caller: 'Gizemli hat', message: 'Doğru ayar gizli odanın yerini veriyor.', evidence: 'Eski Frekans · bulunan iz', fact: 'Bir dalganın saniyedeki titreşim sayısı.', hints: ['Bir dalganın saniyedeki titreşim sayısı.', 'İlk harf: F', 'Başlangıç: FR']),
  CaseLevel('Gizli Oda', 'Elektrik devresini açıp kapatan anahtar.', 'ŞALTER', 'Devre açıldı; masadaki kutu aydınlandı.', 'Devre açıldı; masadaki kutu aydınlandı.', caller: 'Gizemli hat', message: 'Devre açıldı; masadaki kutu aydınlandı.', evidence: 'Gizli Oda · bulunan iz', fact: 'Elektrik devresini açıp kapatan anahtar.', hints: ['Elektrik devresini açıp kapatan anahtar.', 'İlk harf: Ş', 'Başlangıç: ŞA']),
  CaseLevel('Son Şifre', 'Kilidi açmak için kullanılan dişli araç.', 'ANAHTAR', 'Kutudan son görevlinin fotoğrafı çıktı.', 'Kutudan son görevlinin fotoğrafı çıktı.', caller: 'Gizemli hat', message: 'Kutudan son görevlinin fotoğrafı çıktı.', evidence: 'Son Şifre · bulunan iz', fact: 'Kilidi açmak için kullanılan dişli araç.', hints: ['Kilidi açmak için kullanılan dişli araç.', 'İlk harf: A', 'Başlangıç: AN']),
  CaseLevel('Bilinmeyen Kişi', 'Santralde telefon bağlantılarını kuran görevli.', 'OPERATÖR', 'Görevli yardım çağrılarını yıllarca saklamış.', 'Görevli yardım çağrılarını yıllarca saklamış.', caller: 'Gizemli hat', message: 'Görevli yardım çağrılarını yıllarca saklamış.', evidence: 'Bilinmeyen Kişi · bulunan iz', fact: 'Santralde telefon bağlantılarını kuran görevli.', hints: ['Santralde telefon bağlantılarını kuran görevli.', 'İlk harf: O', 'Başlangıç: OP']),
  CaseLevel('Son Telefon', 'Bir olayın sanıldığı gibi değil, olduğu hâli.', 'GERÇEK', 'Aramalar kaybolanların sesini unutturmamak içinmiş.', 'Aramalar kaybolanların sesini unutturmamak içinmiş.', caller: 'Gizemli hat', message: 'Aramalar kaybolanların sesini unutturmamak içinmiş.', evidence: 'Son Telefon · bulunan iz', fact: 'Bir olayın sanıldığı gibi değil, olduğu hâli.', hints: ['Bir olayın sanıldığı gibi değil, olduğu hâli.', 'İlk harf: G', 'Başlangıç: GE']),
];

class CaseFile {
  final int id;
  final String title, saveKey, ending;
  final List<CaseLevel> levels;
  const CaseFile(this.id, this.title, this.saveKey, this.levels, this.ending);
}

final caseFiles = <CaseFile>[
  CaseFile(0, 'Kayıp Emanet', 'case_kayip_emanet_v1', caseLevels, 'Saat sahibinin izniyle onarıma götürülmüştü.'),
  CaseFile(1, 'Gece Yarısı Treni', 'case_gece_yarisi_treni_v1', List.unmodifiable(_newCaseLevels.take(12)), 'Tren kaybolmamıştı. Makinist, kapanan yoldan yolcuları kurtarmak için yan hatta sığınmıştı. Defteri gerçeği ortaya çıkardı.'),
  CaseFile(2, 'Son Bağlantı', 'case_son_baglanti_v1', List.unmodifiable(_newCaseLevels.skip(12)), 'Eski operatör, yardım çağrılarını kayıtlarda korumuştu. Gizemli hat bu sesleri sana ulaştırdı. Kayıp saat, tren ve santral artık aynı hikâyede birleşti.'),
];
const _caseActs = ['Kilitli Arşiv', 'Yanlış Hesap', 'Son Kayıt'];


class CaseProgress {
  final int caseId;
  List<CaseLevel> get caseLevels => caseFiles[caseId].levels;
  final Set<int> solved;
  final Map<int, int> hints;
  final Set<int> calls;
  int current;
  bool closed;
  CaseProgress(
      {this.caseId = 0,
      Set<int>? solved,
      Map<int, int>? hints,
      Set<int>? calls,
      this.current = 0,
      this.closed = false})
      : solved = solved ?? {},
        hints = hints ?? {},
        calls = calls ?? {};

  int get unlocked {
    var i = 0;
    while (i < caseLevels.length - 1 && solved.contains(i)) {
      i++;
    }
    return i;
  }

  bool get allSolved => solved.length == caseLevels.length;

  static Future<CaseProgress> load([int caseId = 0]) async {
    final pref = await SharedPreferences.getInstance();
    try {
      final raw = pref.getString(caseFiles[caseId].saveKey);
      if (raw == null) return CaseProgress(caseId: caseId);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      Set<int> indices(dynamic value) => value is List
          ? value
              .whereType<int>()
              .where((i) => i >= 0 && i < caseFiles[caseId].levels.length)
              .toSet()
          : {};
      final progress = CaseProgress(
          caseId: caseId, solved: indices(data['solved']), calls: indices(data['calls']));
      if (data['hints'] is Map) {
        for (final entry in (data['hints'] as Map).entries) {
          final i = int.tryParse(entry.key.toString());
          if (i != null &&
              i >= 0 &&
              i < caseFiles[caseId].levels.length &&
              entry.value is int) {
            progress.hints[i] = (entry.value as int).clamp(0, 3);
          }
        }
      }
      progress.current = data['current'] is int
          ? (data['current'] as int).clamp(0, progress.unlocked)
          : 0;
      progress.closed = data['closed'] == true && progress.allSolved;
      return progress;
    } catch (_) {
      return CaseProgress(caseId: caseId);
    }
  }

  Future<void> save() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(
        caseFiles[caseId].saveKey,
        jsonEncode({
          'solved': solved.toList()..sort(),
          'calls': calls.toList()..sort(),
          'hints': hints.map((key, value) => MapEntry('$key', value)),
          'current': current,
          'closed': closed,
        }));
  }
}

class CaseDetailPage extends StatefulWidget {
  final int caseId;
  const CaseDetailPage({super.key, this.caseId = 0});
  @override
  State<CaseDetailPage> createState() => _CaseDetailPageState();
}

class _CaseDetailPageState extends State<CaseDetailPage> {
  List<CaseLevel> get caseLevels => caseFiles[widget.caseId].levels;
  CaseProgress? progress;
  bool opening = false;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final value = await CaseProgress.load(widget.caseId);
    if (mounted) setState(() => progress = value);
  }

  Future<void> _open() async {
    if (opening || progress == null) return;
    setState(() => opening = true);
    try {
      await Navigator.push<void>(
          context,
          MaterialPageRoute(
              builder: (_) => progress!.allSolved && (!progress!.closed || widget.caseId > 0)
                  ? CaseFinalePage(caseId: widget.caseId)
                  : GamePage(adventure: true, caseId: widget.caseId)));
      if (mounted) await _refresh();
    } finally {
      if (mounted) setState(() => opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = progress;
    return Scaffold(
        appBar: AppBar(title: Text(caseFiles[widget.caseId].title)),
        body: Stack(children: [
      Positioned.fill(
          child: Image.asset('assets/art/scene.png', fit: BoxFit.cover)),
      Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: .72))),
      SafeArea(
          child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
                      children: [
                        const Icon(Icons.phone_in_talk, color: _gold, size: 34),
                        const SizedBox(height: 12),
                        const Text('KELİME HATTI',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: _paper,
                                fontFamily: 'serif',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2)),
                        const SizedBox(height: 7),
                        const Text('Her aramanın bir hikâyesi var.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFFB8C1AE), fontSize: 15)),
                        const SizedBox(height: 30),
                        Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                                color: const Color(0xFF142B2A),
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: const Color(0xFF776442))),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('DOSYA ${(widget.caseId + 1).toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                          color: _gold,
                                          fontSize: 11,
                                          letterSpacing: 1.5)),
                                  const SizedBox(height: 10),
                                  Text(caseFiles[widget.caseId].title,
                                      style: TextStyle(
                                          color: _paper,
                                          fontFamily: 'serif',
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  Text(
                                      widget.caseId == 0 ? 'Saat kayıp!\nKısa bulmacaları çöz, izleri birleştir.' : 'Kısa bulmacaları çöz, gizemli hattın izini sür.',
                                      style: TextStyle(
                                          color: Color(0xFFD4D8CB),
                                          fontSize: 15,
                                          height: 1.5)),
                                  const SizedBox(height: 20),
                                  Text(
                                      p == null
                                          ? 'Dosya yükleniyor…'
                                          : p.closed
                                              ? 'DOSYA ÇÖZÜLDÜ · ${p.solved.length}/12 kanıt'
                                              : '${p.solved.length}/12 kanıt toplandı',
                                      style: const TextStyle(
                                          color: _gold, fontSize: 12)),
                                  const SizedBox(height: 9),
                                  LinearProgressIndicator(
                                      value: (p?.solved.length ?? 0) /
                                          caseLevels.length,
                                      color: _gold,
                                      backgroundColor: const Color(0xFF30413A),
                                      minHeight: 5,
                                      borderRadius: BorderRadius.circular(3)),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                          key: const ValueKey('open-case'),
                                          onPressed: p == null || opening
                                              ? null
                                              : _open,
                                          style: FilledButton.styleFrom(
                                              backgroundColor: _green,
                                              foregroundColor: _paper,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16)),
                                          icon: Icon(p?.closed == true
                                              ? Icons.folder_open
                                              : Icons.phone),
                                          label: Text(p?.closed == true
                                              ? 'Dosyayı yeniden incele'
                                              : p?.allSolved == true
                                                  ? 'Dosya finalini aç'
                                                  : (p?.solved.isNotEmpty ??
                                                          false)
                                                      ? 'Kaldığın yerden devam et'
                                                      : 'Hattı aç'))),
                                  if (p != null)
                                    TextButton.icon(
                                      icon: const Icon(Icons.replay),
                                      label: const Text('Bölüm seç · Yeniden oyna'),
                                      onPressed: opening ? null : () async {
                                        final selected = await showModalBottomSheet<int>(
                                          context: context,
                                          builder: (ctx) => SafeArea(child: ListView(
                                            children: List.generate(12, (i) => ListTile(
                                              enabled: i <= p.unlocked,
                                              leading: Icon(p.solved.contains(i) ? Icons.check_circle : Icons.lock_open),
                                              title: Text('${widget.caseId * 12 + i + 1}. ${caseLevels[i].name}'),
                                              onTap: i > p.unlocked ? null : () => Navigator.pop(ctx, i),
                                            )),
                                          )),
                                        );
                                        if (selected == null || !mounted) return;
                                        p.current = selected;
                                        await p.save();
                                        if (!context.mounted) return;
                                        await Navigator.push<void>(context, MaterialPageRoute(builder: (_) => GamePage(adventure: true, caseId: widget.caseId)));
                                        await _refresh();
                                      },
                                    ),
                                  const SizedBox(height: 8),
                                  const Text('12 kısa bulmaca · tek gizem',
                                      style: TextStyle(
                                          color: Color(0xFF9AA99D),
                                          fontSize: 12)),
                                ])),
                        const SizedBox(height: 20),
                        ...List.generate(3, (act) {
                          final done =
                              p?.solved.where((i) => i ~/ 4 == act).length ?? 0;
                          final unlocked =
                              act == 0 || (p?.unlocked ?? 0) >= act * 4;
                          return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                  done == 4
                                      ? Icons.check_circle_outline
                                      : unlocked
                                          ? Icons.radio_button_checked
                                          : Icons.lock_outline,
                                  color: unlocked ? _gold : Colors.white38),
                              title: Text(
                                  '${act + 1}. perde · ${widget.caseId == 0 ? _caseActs[act] : ['İlk İz', 'Gizli Yol', 'Son Çağrı'][act]}',
                                  style: TextStyle(
                                      color: unlocked ? _paper : Colors.white38,
                                      fontFamily: 'serif')),
                              trailing: Text('$done/4',
                                  style: const TextStyle(color: _gold)));
                        }),
                        const Divider(color: Color(0xFF4B5143), height: 28),
                        OutlinedButton.icon(
                            onPressed: p == null
                                ? null
                                : () => _showNotebook(context, p),
                            icon: const Icon(Icons.menu_book),
                            label: const Text('Kanıt ve Bilgi Defteri')),
                        const SizedBox(height: 10),
                        TextButton.icon(
                            onPressed: () => Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const GamePage())),
                            icon: const Icon(Icons.history),
                            label: const Text('Eski Hat · İlk 10 bölüm')),
                        const SizedBox(height: 10),
                        const Text(
                            'Hikâye kurgudur. Bilgi kartları gerçek kavramları açıklar.\nİlerlemen bu cihazda otomatik kaydedilir.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                height: 1.5)),
                      ]))))
    ]));
  }
}

Future<void> _showNotebook(BuildContext context, CaseProgress progress) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF132B2A),
      builder: (sheetContext) => SafeArea(
          child: SizedBox(
              height: MediaQuery.sizeOf(sheetContext).height * .88,
              child: Column(children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
                    child: Row(children: [
                      const Icon(Icons.menu_book, color: _gold),
                      const SizedBox(width: 12),
                      const Expanded(
                          child: Text('Kanıt ve Bilgi Defteri',
                              style: TextStyle(
                                  color: _paper,
                                  fontFamily: 'serif',
                                  fontSize: 21))),
                      IconButton(
                          tooltip: 'Defteri kapat',
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close)),
                    ])),
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            '${progress.solved.length}/12 kanıt · ${caseFiles[progress.caseId].title}',
                            style: const TextStyle(color: _gold)))),
                if (progress.solved.isEmpty)
                  const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                          'İlk kelimeyi çözdüğünde bulduğun kanıt ve öğrendiğin bilgi burada saklanacak.',
                          style: TextStyle(color: _paper, height: 1.5))),
                Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: caseFiles[progress.caseId].levels.length,
                        itemBuilder: (context, i) {
                          final level = caseFiles[progress.caseId].levels[i];
                          final found = progress.solved.contains(i);
                          if (!found) {
                            return ListTile(
                                leading: const Icon(Icons.lock_outline,
                                    color: Colors.white24),
                                title: Text('${i + 1}. kanıt · Henüz bulunmadı',
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 13)));
                          }
                          return Card(
                              color: const Color(0xFF203A35),
                              child: ExpansionTile(
                                key: ValueKey('evidence-$i'),
                                collapsedIconColor: _gold,
                                iconColor: _gold,
                                leading: const Icon(Icons.description_outlined,
                                    color: _gold),
                                title: Text('${i + 1}. ${level.evidence}',
                                    style: const TextStyle(
                                        color: _paper,
                                        fontFamily: 'serif',
                                        fontSize: 17)),
                                subtitle: Text(level.answer,
                                    style: const TextStyle(
                                        color: _gold,
                                        fontSize: 11,
                                        letterSpacing: 1)),
                                childrenPadding:
                                    const EdgeInsets.fromLTRB(18, 0, 18, 18),
                                children: [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: _EvidenceContent(level: level))
                                ],
                              ));
                        })),
              ]))),
    );

class _EvidenceContent extends StatelessWidget {
  final CaseLevel level;
  const _EvidenceContent({required this.level});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(level.story, style: const TextStyle(color: _paper, height: 1.5)),
        const Divider(color: Color(0xFF617057), height: 28),
        const Text('CEBİNE BİR BİLGİ',
            style: TextStyle(color: _gold, fontSize: 11, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Text(level.fact,
            style: const TextStyle(color: Color(0xFFD2D9C8), height: 1.5)),
        const SizedBox(height: 10),
        Text(level.source,
            style: const TextStyle(color: Color(0xFF9DB09D), fontSize: 11)),
        if (level.sourceUrl != null)
          TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: level.sourceUrl!));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Kaynak bağlantısı kopyalandı.')));
                }
              },
              icon: const Icon(Icons.copy, size: 14),
              label: const Text('Kaynak bağlantısını kopyala',
                  style: TextStyle(fontSize: 11))),
      ]);
}

class CaseFinalePage extends StatefulWidget {
  final int caseId;
  const CaseFinalePage({super.key, this.caseId = 0});
  @override
  State<CaseFinalePage> createState() => _CaseFinalePageState();
}

class _CaseFinalePageState extends State<CaseFinalePage> {
  CaseProgress? progress;
  int? choice;
  bool saving = false;
  String? feedback;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await CaseProgress.load(widget.caseId);
    if (mounted) setState(() => progress = value);
  }

  Future<void> _resolve() async {
    if (progress == null || !progress!.allSolved || choice == null || saving) {
      return;
    }
    if (widget.caseId == 0 && choice != 1) {
      setState(() => feedback = 'İzin + usta + iade makbuzu. Bir daha düşün!');
      return;
    }
    setState(() => saving = true);
    progress!.closed = true;
    try {
      await progress!.save();
      if (mounted) setState(() => feedback = null);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = progress;
    return Scaffold(
        appBar: AppBar(
            title:
                const Text('Son Karar', style: TextStyle(fontFamily: 'serif'))),
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(padding: const EdgeInsets.all(24), children: [
                  Icon(
                      p?.closed == true
                          ? Icons.verified_outlined
                          : Icons.account_tree_outlined,
                      color: _gold,
                      size: 48),
                  const SizedBox(height: 18),
                  Text(
                      p?.closed == true
                          ? 'DOSYA ÇÖZÜLDÜ'
                          : 'Kanıtlar ne anlatıyor?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: _paper, fontFamily: 'serif', fontSize: 29)),
                  const SizedBox(height: 20),
                  if (p == null)
                    const Center(child: CircularProgressIndicator())
                  else if (!p.allSolved)
                    const Text(
                        'Son kararı vermeden önce 12 kanıtı da bulmalısın.',
                        style: TextStyle(color: _paper))
                  else if (widget.caseId > 0) ...[
                    Text(caseFiles[widget.caseId].ending, style: const TextStyle(color: _paper, fontSize: 20, height: 1.5)),
                    const SizedBox(height: 20),
                    Text(p.closed ? '🏆 Dosya çözüldü · 12/12' : '12 kanıt tamamlandı!', style: const TextStyle(color: _gold)),
                    FilledButton(onPressed: saving ? null : () async {
                      setState(() => saving = true);
                      try {
                        p.closed = true;
                        await p.save();
                        if (context.mounted) Navigator.popUntil(context, (route) => route.isFirst);
                      } finally { if (mounted) setState(() => saving = false); }
                    }, child: const Text('Dosyayı tamamla · Ana menü')),
                  ] else if (p.closed) ...[
                    const Text('Saat çalınmamıştı.',
                        style: TextStyle(
                            color: _gold, fontFamily: 'serif', fontSize: 24)),
                    const SizedBox(height: 14),
                    const Text(
                        'Saat satılmamıştı. Leyla izin vermiş, usta onarıma almıştı. Eksik kayıt herkesi yanıltmıştı. Sen izleri birleştirdin!',
                        style: TextStyle(
                            color: _paper, height: 1.6, fontSize: 16)),
                    const SizedBox(height: 24),
                    const Text('İdil’den son mesaj',
                        style: TextStyle(color: _gold)),
                    const SizedBox(height: 8),
                    const Text(
                        '“Saati buldun. Ama bu hat neden yalnızca seni arıyor?”',
                        style: TextStyle(
                            color: _paper,
                            fontFamily: 'serif',
                            fontStyle: FontStyle.italic,
                            fontSize: 20,
                            height: 1.4)),
                    const SizedBox(height: 24),
                    FilledButton(
                        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                        child: const Text('Ana menüye dön')),
                  ] else ...[
                    const Text(
                        '09.00 · Sahibinin sevk izni\n10.00 · 42 numaralı saat atölyeye teslim\n10.15 · “Satış yok” mesajı',
                        style: TextStyle(color: _gold, height: 1.8)),
                    const SizedBox(height: 20),
                    const Text('Saat neden vitrinde değildi?',
                        style: TextStyle(
                            color: _paper, fontSize: 19, fontFamily: 'serif')),
                    const SizedBox(height: 12),
                    ...List.generate(
                        3,
                        (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: OutlinedButton(
                              key: ValueKey('conclusion-$i'),
                              style: OutlinedButton.styleFrom(
                                  backgroundColor: choice == i
                                      ? const Color(0xFF294B3B)
                                      : null,
                                  padding: const EdgeInsets.all(16),
                                  side: BorderSide(
                                      color: choice == i
                                          ? _gold
                                          : const Color(0xFF526153))),
                              onPressed: saving
                                  ? null
                                  : () => setState(() {
                                        choice = i;
                                        feedback = null;
                                      }),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      const [
                                        'Koleksiyoncuya satılmıştı.',
                                        'Sahibinin izniyle onarıma götürülmüştü.',
                                        'Takas teklifi kabul edilmişti.'
                                      ][i],
                                      style: const TextStyle(
                                          color: _paper, height: 1.4))),
                            ))),
                    if (feedback != null)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(feedback!,
                              style:
                                  const TextStyle(color: _gold, height: 1.5))),
                    FilledButton(
                        key: const ValueKey('resolve-case'),
                        onPressed: choice == null || saving ? null : _resolve,
                        child: const Text('Dosyayı sonuçlandır')),
                    TextButton.icon(
                        onPressed: () => _showNotebook(context, p),
                        icon: const Icon(Icons.menu_book),
                        label: const Text('Kanıtları yeniden incele')),
                  ],
                ]))));
  }
}

class CaseDeskPage extends StatefulWidget {
  const CaseDeskPage({super.key});
  @override
  State<CaseDeskPage> createState() => _CaseDeskPageState();
}

class _CaseDeskPageState extends State<CaseDeskPage> {
  List<CaseProgress>? progress;
  @override
  void initState() { super.initState(); _refresh(); }
  Future<void> _refresh() async {
    final values = await Future.wait(List.generate(3, CaseProgress.load));
    if (mounted) setState(() => progress = values);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('KELİME HATTI · Dosyalar')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('36 bölüm · 3 gizem', style: TextStyle(color: _gold, fontSize: 22)),
      const SizedBox(height: 16),
      for (final file in caseFiles)
        Card(child: ListTile(
          leading: Icon(progress?[file.id].closed == true ? Icons.verified : Icons.folder_open, color: _gold),
          title: Text(file.title),
          subtitle: Text('Dosya 0${file.id + 1} · Bölüm ${file.id * 12 + 1}–${file.id * 12 + 12}\n${progress?[file.id].solved.length ?? 0}/12 · ${progress?[file.id].closed == true ? "Tamamlandı · Yeniden oyna" : "Devam et / Bölüm seç"}'),
          isThreeLine: true,
          onTap: progress == null ? null : () async {
            await Navigator.push<void>(context, MaterialPageRoute(builder: (_) => CaseDetailPage(caseId: file.id)));
            await _refresh();
          },
        )),
    ]),
  );
}
