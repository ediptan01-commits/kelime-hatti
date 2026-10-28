# Kelime Hattı — Kayıp Emanet

Eski bir telefon hattından gelen yazılı çağrılarla çözülen, Türkçe bir dedektif ve kelime oyunu.

## 1.1 sürümü

- **Kayıp Emanet:** 12 bölümlük, üç perdeli ve tamamlanabilir ilk macera.
- Dört karakterden yazılı çağrılar; tekrar okuma seçeneği.
- Doğru cevaplarla toplanan 12 kanıt ve kısa bilgi kartları.
- Kanıt ve Bilgi Defteri; kaynak bağlantılarını kopyalama.
- Üç aşamalı ücretsiz ipucu ve ilk harflerle yardım.
- Kanıtları birleştirerek verilen son karar ve dosyanın çözümü.
- Cihazda otomatik ilerleme kaydı; eski on bölüm ve eski kayıtlar ayrı korunur.
- Önceden onaylanan kadran görselleri ve gerçek telefon sesleri korunur.

Hikâye ve karakterler kurgudur. Bilgi kartlarında genel kavram açıklamaları ile ilgili kurumsal kaynaklar ayrılmıştır. İlk macera arşiv araştırması, müze kayıtları, haberleşme ve temel ekonomi kavramlarını kullanır.

## Oynanış

Dosya masasından **Hattı aç** ile başla. Çağrıyı oku, cevabı kadranı çevirerek yaz ve kontrol et. Sol üstteki defter bulunan kanıtları gösterir; sağ üstteki dosya menüsünden çağrıyı yeniden okuyabilir veya açılmış bölümlere dönebilirsin. Eski oyun ana sayfadaki **Eski Hat** bölümündedir.

## Doğrulama

`flutter pub get`, `flutter analyze`, `flutter test`

Android proje dosyaları GitHub Actions iş akışında oluşturulur. İş akışı analiz ve testlerden sonra release APK üretir.

Yerel testler tüm 12 bölümün çözümünü, final kararını, kanıt defterini, ipuçlarını, kayıtların yeniden yüklenmesini, eski ilerlemenin korunmasını ve kadran/ses geçişlerini kapsar.
