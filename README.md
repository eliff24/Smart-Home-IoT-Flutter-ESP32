# flutter_application_1

# 🏠 Mobil Uygulama Destekli Akıllı Ev Sistemi (IoT)

Bu proje, uçtan uca (End-to-End) tasarlanmış, gerçek zamanlı çalışan bir Nesnelerin İnterneti (IoT) ekosistemidir. 

Proje; fiziksel donanım katmanı, NoSQL bulut haberleşme katmanı ve reaktif mobil uygulama katmanı olmak üzere 3 temel yapıdan oluşmaktadır.

---

## 🛠️ Kullanılan Teknolojiler ve Donanımlar

### 1. Gömülü Sistem & Donanım Katmanı
* **Mikrodenetleyici:** ESP32 (32-bit çift çekirdekli işlemci, yerleşik Wi-Fi modülü)
* **Sensörler:** 
  * DHT (Sıcaklık ve Nem Sensörü)
  * Analog Gaz Sensörü (Metan, bütan, LPG vb. takibi için)
  * Yağmur Durumu Tespit Sensörü
  * LDR (Ortam Işık Şiddeti Sensörü)
* **Aktatörler:** Bağımsız 4 adet Oda LED'i (Salon, Mutfak, Yatak Odası, Banyo) ve Motorlu Vana Mekanizması simülasyonu.

### 2. Bulut & Haberleşme Katmanı
* **Google Firebase Realtime Database:** JSON tabanlı, gerçek zamanlı NoSQL bulut veritabanı mimarisi. Donanım ve mobil uygulama arasında çift yönlü, düşük gecikmeli WebSocket haberleşmesi sağlar.

### 3. Mobil Uygulama Katmanı
* **Flutter Framework (Dart):** Çoklu platform destekli reaktif arayüz mimarisi. `StreamBuilder` entegrasyonu sayesinde buluttaki veri değişimlerini sayfayı yenilemeye gerek kalmadan anlık olarak ekrana yansıtır.

---

## 🚀 Projenin Özgün Değeri ve Mühendislik Çözümleri

* **Gecikme (Latency) ve Döngü Optimizasyonu:** Standart gömülü sistem döngülerindeki kilitlenmeleri önlemek adına `void loop()` süresi 200 ms'ye optimize edilmiştir. Mobil uygulamadan gelen lamba tetikleme komutları saniyede 5 kez sorgulanarak milisaniyeler mertebesinde yürütülür.
* **Asenkron Zamanlayıcı Sayaç (Counter) Mimarisi:** Sürekli veri gönderiminin bulut kotasını yormasını ve hızlı okumada kararsızlaşan DHT sensörünün fiziksel sınırlarını aşmak için gömülü kodda özel bir sayaç kurulmuştur. Lambalar anlık dinlenirken, sensör verileri 10 döngüde bir (2000 ms'de bir) asenkron olarak Firebase'e basılır.
* **Sınır Bilişim (Edge Computing) ile Kesintisiz Güvenlik:** Can ve mal güvenliği senaryoları buluttan bağımsız hale getirilmiştir. Evdeki Wi-Fi bağlantısı tamamen kopsa dahi, gaz sensörü kritik eşiği (>300) aştığı anda ESP32 yerel kod bloğu üzerinden motorlu vanayı otomatik olarak "KAPALI" konumuna getirir ve otonom güvenliği lokal düzeyde sürdürür.

---

## 📂 Proje Klasör Yapısı
* `/lib` : Flutter mobil uygulama kaynak kodları ve Firebase Stream yapılandırmaları.
* `/src` (veya ilgili klasörün) : ESP32 C++ gömülü yazılım kaynak kodları ve sensör kalibrasyon algoritmaları.
