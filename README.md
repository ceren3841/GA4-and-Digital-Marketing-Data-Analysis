# Google Analytics 4 & Dijital Pazarlama Veri Analizi Projesi

Bu projede, PostgreSQL (DBeaver) kullanarak Google ve Facebook reklamlarının performans verilerini analiz ettim. Ayrıca Google Cloud BigQuery üzerinde ham GA4 e-ticaret verileriyle çalışarak kullanıcı dönüşüm hunilerini (funnel) çıkardım ve landing page performanslarını karşılaştırdım.

## Kullandığım Teknolojiler ve Yetenekler
* **Google Cloud Platform (GCP):** BigQuery Standard SQL
* **İlişkisel Veritabanları:** PostgreSQL (DBeaver)
* **SQL Konseptleri:** CTEs (`WITH`), Multi-table Joins, Window Functions (`OVER (PARTITION BY)`), Gaps & Islands Mantığı (`ROW_NUMBER()`), Regex parsing (`REGEXP_EXTRACT`), Sorgu Optimizasyonu.

---

## Proje İçeriği ve Çözümlerim

### Bölüm 1: Dijital Pazarlama Analitiği (PostgreSQL / DBeaver)
* **Harcama Özetleri:** Google ve Facebook Ads verilerini tek bir yapıda birleştirerek platform bazında günlük ortalama, maksimum ve minimum harcama metriklerini çıkardım.
* **ROMI Performansı:** Toplam Pazarlama Yatırımının Geri Dönüşü (ROMI) metriğini hesaplayarak, bütçenin en verimli kullanıldığı en yüksek performanslı ilk 5 günü azalan şekilde sıraladım.
* **Haftalık ve Aylık Trendler:** `DATE_TRUNC` fonksiyonu kullanarak haftalık bazda ciro (value) rekoru kıran kampanyaları ve aylık bazda erişimini (reach) en çok artıran dönemleri tespit ettim.
* **Gaps and Islands Analizi:** Reklam gösterimlerindeki boşlukları (kesintileri) atlayarak, her bir reklam seti (adset) için ardışık aktif gün sayılarını hesapladım ve en uzun kesintisiz yayınlanan kampanyayı tespit ettim.

### Bölüm 2: BI Raporları İçin GA4 Veri Hazırlığı (Google Cloud / BigQuery)
* **Zaman Damgası Dönüşümü:** GA4 ham verisinde mikrosaniye cinsinden tutulan `event_timestamp` alanını `TIMESTAMP_MICROS` ile okunabilir zaman biçimine dönüştürdüm.
* **Oturum Tekilleştirme:** Aynı oturum kimliğine (`session_id`) sahip farklı kullanıcılar olabileceği için `user_pseudo_id` ve `ga_session_id` alanlarını `UNNEST` yöntemiyle çıkararak tekil oturum takibi sağladım.
* **Etkinlik Filtreleme:** Sadece 2021 yılına ait e-ticaret adımlarını kapsayan belirli kritik etkinlikleri (`session_start`, `view_item`, `add_to_cart`, `begin_checkout`, `purchase` vb.) filtreleyerek BI raporlarına hazır temiz bir veri kümesi oluşturdum.

### Bölüm 3: Trafik Kanalları ve Tarih Bazında Dönüşüm Hesaplaması (BigQuery)
* **Dönüşüm Hunusu (Funnel) Kurgusu:** Kullanıcıların satın alma yolculuğunu kanal bazında görebilmek için conditional aggregation (`MAX(IF(...))`) mantığıyla her oturumun hangi adımlardan geçtiğini işaretledim.
* **Kanal Performansı:** Sonuçları tarih (`event_date`), kaynak (`source`), araç (`medium`) ve kampanya (`campaign`) kırılımlarında gruplayarak; toplam oturum sayısı, sepete ekleme, ödeme adımına geçme ve başarılı satın alma sayılarını (`visit_to_purchase`) netleştirdim.

### Bölüm 4: Açılış Sayfaları (Landing Pages) Arasındaki Dönüşüm Karşılaştırması (BigQuery)
* **Regex ile Temiz URL Çıkarımı:** `page_location` parametresindeki karmaşık URL yapılarından `REGEXP_EXTRACT` kullanarak temiz sayfa yollarını (`page_path`) ayıkladım.
* **İlk Temas (First Touch) Analizi:** Kullanıcıların oturumu başlattığı (`session_start`) ilk sayfayı "Landing Page" olarak belirledim ve farklı sayfalarda gerçekleşen `purchase` etkinliklerini aynı kullanıcı ve oturum kombinasyonuyla (`user_id + session_id`) eşleştirdim.
* **Dönüşüm Oranı (CR) Hesaplaması:** 2020 yılı verileri üzerinde, her bir açılış sayfasının benzersiz oturum sayısını, toplam satın alma sayısını ve `SAFE_DIVIDE` kullanarak hata korumalı gerçek satın alma dönüşüm oranlarını (Conversion Rate) hesaplayıp listeledim.

