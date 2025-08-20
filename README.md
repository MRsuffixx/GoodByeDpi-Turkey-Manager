# GoodByeDPI Service Manager

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg) ![Windows](https://img.shields.io/badge/Platform-Windows-lightgrey.svg) ![License](https://img.shields.io/badge/License-Free-green.svg)


**Türkiye için DNS zorlamasını kaldıran GoodByeDPI servisini yönetmek için geliştirilmiş profesyonel PowerShell scripti.**

## 📋 Özellikler

- ✅ **Otomatik Yönetici Yetkilendirme**: Script kendiliğinden yönetici izni ister
- 🎯 **Kullanıcı Dostu Menü**: Renkli ve anlaşılır arayüz
- 🏗️ **Akıllı Mimari Algılama**: x86/x64 sistemleri otomatik algılar
- ⚙️ **Güvenli Servis Yönetimi**: Servisleri güvenli şekilde kurar/kaldırır
- 🌐 **Türkiye Özel DNS Ayarları**: Önceden yapılandırılmış DNS sunucuları
- 🔧 **Hata Kontrolü**: Kapsamlı hata yönetimi ve kullanıcı bildirimleri

## 🚀 Kurulum ve Kullanım

### Adım 1: Dosyaları Hazırlama
1. **GoodByeDPI** dosyalarınızı şu yapıda düzenleyin:
   ```
   📁 GoodByeDPI Klasörü/
   ├── 📄 GoodByeDPI-Manager.ps1
   ├── 📄 Launch-GoodByeDPI-Manager.bat (opsiyonel)
   ├── 📁 x86/
   │   └── 📄 goodbyedpi.exe
   └── 📁 x64/
       └── 📄 goodbyedpi.exe
   ```

### Adım 2: PowerShell Yürütme İzni (Tek Sefer)
PowerShell scriptlerinin çalışabilmesi için Windows'ta izin vermeniz gerekir:

1. **Başlat** butonuna sağ tık → **"Windows PowerShell (Yönetici)"** seçin
2. Şu komutu çalıştırın:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. **Y** yazıp **Enter** basın

### Adım 3: Scripti Çalıştırma

**Seçenek A: Doğrudan PowerShell Script**
- `GoodByeDPI-Manager.ps1` dosyasına çift tık yapın

**Seçenek B: Batch Launcher (Önerilen)**
- `Launch-GoodByeDPI-Manager.bat` dosyasına çift tık yapın

**Seçenek C: PowerShell'den Manuel**
```powershell
cd "C:\GoodByeDPI\klasör\yolu"
.\GoodByeDPI-Manager.ps1
```

## 🎮 Menü Kullanımı

Script çalıştığında karşınıza şu menü çıkacak:

```
==================================================================
              GoodByeDPI Service Manager v1.0
          DNS Bypass Service for Turkey - PowerShell Edition
==================================================================

🔧 Sistem Bilgileri:
   📁 Çalışma Dizini: C:\GoodByeDPI
   🏗️  Mimari: x64
   👤 Çalışma Modu: Yönetici

Lütfen bir seçenek seçin:

  [0] GoodByeDPI Servisini Kur & Başlat
      └─ DNS zorlama kaldırma servisini Türkiye ayarlarıyla kurar

  [1] GoodByeDPI Servisini Durdur & Kaldır  
      └─ GoodByeDPI ve ilgili tüm servisleri tamamen kaldırır

  [Q] Çıkış

Seçiminizi girin (0, 1, veya Q):
```

### Seçenek 0: Servis Kurulumu
- GoodByeDPI servisini Windows servisi olarak kurar
- Türkiye için özel DNS ayarlarını yapılandırır
- Servisi otomatik başlatır ve sistem başlangıcında çalışacak şekilde ayarlar
- **DNS Sunucuları**: 77.88.8.8 ve 2a02:6b8::feed:0ff

### Seçenek 1: Servis Kaldırma
- GoodByeDPI servisini durdurur ve kaldırır
- WinDivert ve WinDivert14 servislerini de temizler
- Sistemden tamamen kaldırır

## ⚙️ Teknik Detaylar

### Servis Yapılandırması
```
Servis Adı: GoodbyeDPI
Yürütme Parametreleri: -5 --set-ttl 5 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253
Başlatma: Otomatik (sistem başlangıcında)
Açıklama: Türkiye için DNS zorlamasını kaldırır
```

### Sistem Gereksinimleri
- **İşletim Sistemi**: Windows 7/8/10/11
- **PowerShell**: Versiyon 5.1 veya üzeri
- **Yetkiler**: Yönetici (Administrator) erişimi
- **Mimari**: x86 veya x64

## 🛠️ Sorun Giderme

### Script açılmıyor / hemen kapanıyor
**Çözüm 1**: PowerShell yürütme politikasını etkinleştirin
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Çözüm 2**: Batch launcher kullanın
- `Launch-GoodByeDPI-Manager.bat` dosyasını çift tıklayın

**Çözüm 3**: Manuel başlatma
```powershell
PowerShell -ExecutionPolicy Bypass -File "GoodByeDPI-Manager.ps1"
```

### "Executable bulunamadı" hatası
- GoodByeDPI dosyalarının doğru klasör yapısında olduğundan emin olun
- `x86` ve `x64` klasörlerinde `goodbyedpi.exe` dosyalarının bulunduğunu kontrol edin

### Servis başlatılamıyor
- Windows Güvenlik Duvarı'nın uygulamayı engellemediğini kontrol edin
- Antivirus programınızın GoodByeDPI'yi engellemediğinden emin olun
- Windows Olay Günlüğü'nden (Event Viewer) detaylı hata bilgilerini kontrol edin

### İzin hataları
- Scripti **Yönetici olarak çalıştır** seçeneğiyle başlatın
- UAC (Kullanıcı Hesap Denetimi) etkinse onay verin

## 📝 Sık Sorulan Sorular

**S: Bu script orijinal GoodByeDPI batch dosyalarımı değiştirir mi?**
C: Hayır, script tamamen bağımsızdır. Orijinal batch dosyalarınız olduğu gibi kalır.

**S: DNS ayarlarını değiştirmem gerekir mi?**
C: Hayır, script zaten otomatik olarak doğru DNS sunucularını yapılandırır.

**S: Servis kurulduktan sonra bilgisayarı yeniden başlatmam gerekir mi?**
C: Hayır, servis hemen aktif olur. Yeniden başlatma sonrasında da otomatik çalışır.

**S: Bu script güvenli mi?**
C: Evet, script sadece Windows servis komutlarını kullanır ve hiçbir zararlı kod içermez. Açık kaynak mantığıyla geliştirilmiştir.

**S: Hangi DNS sunucuları kullanılıyor?**
C: Yandex DNS sunucuları kullanılır: 77.88.8.8 (IPv4) ve 2a02:6b8::feed:0ff (IPv6)

## 🔗 İlgili Bağlantılar

- **GoodByeDPI Projesi**: [GitHub](https://github.com/ValdikSS/GoodbyeDPI)
- **Windows PowerShell Dokümantasyonu**: [Microsoft Docs](https://docs.microsoft.com/powershell/)
- **Windows Servis Yönetimi**: [SC Command Reference](https://docs.microsoft.com/windows-server/administration/windows-commands/sc-create)

## 📞 Destek

Bu script ile ilgili sorunlarınız için:
1. Öncelikle **Sorun Giderme** bölümünü kontrol edin
2. Windows Olay Günlüğü'nden hata detaylarını inceleyin
3. Script çıktısındaki hata mesajlarını not alın

## 📄 Lisans

Bu script ücretsiz olarak kullanılabilir. İhtiyaçlarınıza göre değiştirebilir ve paylaşabilirsiniz.

---
**⚠️ Uyarı**: Bu araç sadece yasal amaçlar için kullanılmalıdır. İnternet erişim kısıtlamalarını aşmak için kullanıldığında yerel yasalara uygunluğu kullanıcının sorumluluğundadır.
