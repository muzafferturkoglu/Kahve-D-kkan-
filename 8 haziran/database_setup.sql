CREATE DATABASE kahve_dukkani_yildiz_puan;
USE kahve_dukkani_yildiz_puan;

CREATE TABLE kd_musteriler (
    musteri_id      VARCHAR(64)     NOT NULL,
    musteri_ad      VARCHAR(64)     NOT NULL,
    musteri_soyad   VARCHAR(64)     NOT NULL,
    musteri_tel     VARCHAR(25)     NOT NULL,
    musteri_email   VARCHAR(250)    NOT NULL UNIQUE,
    musteri_adres   VARCHAR(250)    NULL,
    kayit_tarihi    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(musteri_id)
);

CREATE TABLE kd_urunler (
    urun_id         VARCHAR(64)     NOT NULL,
    urun_ad         VARCHAR(250)    NOT NULL,
    urun_kategori   VARCHAR(250)    NOT NULL,
    urun_fiyat      FLOAT           NOT NULL,
    urun_stok       FLOAT           NOT NULL DEFAULT 0,
    urun_birim      VARCHAR(16)     NOT NULL COMMENT 'Adet, Bardak, Dilim vb.',
    urun_aciklama   VARCHAR(250)    NULL,
    ortalama_puan   FLOAT           DEFAULT 0,
    PRIMARY KEY(urun_id),
    CONSTRAINT chk_urun_fiyat CHECK (urun_fiyat >= 0),
    CONSTRAINT chk_urun_stok CHECK (urun_stok >= 0)
);

CREATE TABLE kd_calisanlar (
    calisan_id          VARCHAR(64)     NOT NULL,
    calisan_ad          VARCHAR(64)     NOT NULL,
    calisan_soyad       VARCHAR(64)     NOT NULL,
    pozisyon            VARCHAR(100)    NOT NULL,
    ise_baslama_tarihi  DATETIME        NOT NULL,
    aktif_mi            BOOLEAN         NOT NULL DEFAULT TRUE,
    PRIMARY KEY(calisan_id)
);

CREATE TABLE kd_siparisler (
    siparis_id          VARCHAR(64)     NOT NULL,
    musteri_id          VARCHAR(64)     NOT NULL,
    urun_id             VARCHAR(64)     NOT NULL,
    calisan_id          VARCHAR(64)     NOT NULL,
    siparis_tarihi      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    miktar              INT             NOT NULL,
    satis_fiyati_birim  FLOAT           NOT NULL COMMENT 'Satış anındaki birim ürün fiyatı',
    toplam_tutar        FLOAT           NOT NULL COMMENT 'Miktar * SatisFiyatiBirim',
    PRIMARY KEY(siparis_id),
    FOREIGN KEY(musteri_id) REFERENCES kd_musteriler(musteri_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY(urun_id)    REFERENCES kd_urunler(urun_id)       ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY(calisan_id) REFERENCES kd_calisanlar(calisan_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_miktar CHECK (miktar > 0),
    CONSTRAINT chk_satis_fiyati_birim CHECK (satis_fiyati_birim >= 0),
    CONSTRAINT chk_toplam_tutar CHECK (toplam_tutar >= 0)
);

CREATE TABLE kd_degerlendirmeler (
    degerlendirme_id    VARCHAR(64)     NOT NULL,
    musteri_id          VARCHAR(64)     NOT NULL,
    urun_id             VARCHAR(64)     NOT NULL,
    siparis_id          VARCHAR(64)     NOT NULL,
    puan                INT             NOT NULL,
    yorum               TEXT            NULL,
    degerlendirme_tarihi DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(degerlendirme_id),
    FOREIGN KEY(musteri_id) REFERENCES kd_musteriler(musteri_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(urun_id)    REFERENCES kd_urunler(urun_id)       ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(siparis_id) REFERENCES kd_siparisler(siparis_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_puan CHECK (puan >= 1 AND puan <= 5)
);

CREATE TABLE kd_odemeler (
    odeme_id        VARCHAR(64)     NOT NULL,
    musteri_id      VARCHAR(64)     NOT NULL,
    siparis_id      VARCHAR(64)     NULL,
    odeme_tarihi    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    odeme_tutari    FLOAT           NOT NULL,
    odeme_tur       VARCHAR(25)     NOT NULL,
    odeme_aciklama  VARCHAR(250)    NULL,
    PRIMARY KEY(odeme_id),
    FOREIGN KEY(musteri_id) REFERENCES kd_musteriler(musteri_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY(siparis_id) REFERENCES kd_siparisler(siparis_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_odeme_tutari CHECK (odeme_tutari > 0),
    CONSTRAINT chk_odeme_tur CHECK (odeme_tur IN ('Nakit', 'Kredi Kartı', 'Mobil Ödeme'))
);

DELIMITER $$
CREATE PROCEDURE kd_MusteriEkle (
    IN p_musteri_id VARCHAR(64),
    IN p_ad VARCHAR(64),
    IN p_soyad VARCHAR(64),
    IN p_tel VARCHAR(25),
    IN p_email VARCHAR(250),
    IN p_adres VARCHAR(250)
)
BEGIN
    INSERT INTO kd_musteriler(musteri_id, musteri_ad, musteri_soyad, musteri_tel, musteri_email, musteri_adres, kayit_tarihi)
    VALUES (p_musteri_id, p_ad, p_soyad, p_tel, p_email, p_adres, NOW());
END $$

DELIMITER $$

CREATE PROCEDURE kd_MusteriGuncelle (
    IN p_musteri_id VARCHAR(64),
    IN p_ad VARCHAR(64),
    IN p_soyad VARCHAR(64),
    IN p_tel VARCHAR(25),
    IN p_email VARCHAR(250),
    IN p_adres VARCHAR(250)
)
BEGIN
    UPDATE kd_musteriler
    SET
        musteri_ad = p_ad,
        musteri_soyad = p_soyad,
        musteri_tel = p_tel,
        musteri_email = p_email,
        musteri_adres = p_adres
    WHERE musteri_id = p_musteri_id;
END $$

DELIMITER $$

CREATE PROCEDURE kd_MusteriSil (
    IN p_musteri_id VARCHAR(64)
)
BEGIN
    DELETE FROM kd_musteriler WHERE musteri_id = p_musteri_id;
END $$

DELIMITER $$

CREATE PROCEDURE kd_MusterilerHepsi ()
BEGIN
    SELECT musteri_id as ID, musteri_ad as Adı, musteri_soyad as Soyadı, musteri_tel as Telefon, musteri_email as Mail, musteri_adres as Adres, kayit_tarihi as KayıtTarihi
    FROM kd_musteriler;
END $$

DELIMITER $$

CREATE PROCEDURE kd_MusteriBul (
    IN p_filtre VARCHAR(250)
)
BEGIN
    SELECT musteri_id as ID, musteri_ad as Adı, musteri_soyad as Soyadı, musteri_tel as Telefon, musteri_email as Mail, musteri_adres as Adres, kayit_tarihi as KayıtTarihi
    FROM kd_musteriler
    WHERE musteri_id LIKE CONCAT('%', p_filtre, '%') OR
          musteri_ad LIKE CONCAT('%', p_filtre, '%') OR
          musteri_soyad LIKE CONCAT('%', p_filtre, '%') OR
          musteri_tel LIKE CONCAT('%', p_filtre, '%') OR
          musteri_email LIKE CONCAT('%', p_filtre, '%');
END $$

DELIMITER $$

CREATE PROCEDURE kd_MusteriSiparisleriListele (
    IN p_musteri_id VARCHAR(64)
)
BEGIN
    SELECT s.siparis_id AS SiparisID, u.urun_ad AS UrunAdi, s.miktar AS Miktar, s.toplam_tutar AS ToplamTutar, s.siparis_tarihi AS SiparisTarihi
    FROM kd_siparisler s
    JOIN kd_urunler u ON s.urun_id = u.urun_id
    WHERE s.musteri_id = p_musteri_id
    ORDER BY s.siparis_tarihi DESC;
END $$

DELIMITER ;

--

DELIMITER $$
CREATE PROCEDURE kd_UrunEkle (
    IN p_urun_id VARCHAR(64),
    IN p_urun_ad VARCHAR(250),
    IN p_kategori VARCHAR(250),
    IN p_fiyat FLOAT,
    IN p_stok FLOAT,
    IN p_birim VARCHAR(16),
    IN p_aciklama VARCHAR(250)
)
BEGIN
    INSERT INTO kd_urunler(urun_id, urun_ad, urun_kategori, urun_fiyat, urun_stok, urun_birim, urun_aciklama, ortalama_puan)
    VALUES (p_urun_id, p_urun_ad, p_kategori, p_fiyat, p_stok, p_birim, p_aciklama, 0);
END $$

DELIMITER $$

CREATE PROCEDURE kd_UrunGuncelle (
    IN p_urun_id VARCHAR(64),
    IN p_urun_ad VARCHAR(250),
    IN p_kategori VARCHAR(250),
    IN p_fiyat FLOAT,
    IN p_stok FLOAT,
    IN p_birim VARCHAR(16),
    IN p_aciklama VARCHAR(250)
)
BEGIN
    UPDATE kd_urunler
    SET
        urun_ad = p_urun_ad,
        urun_kategori = p_kategori,
        urun_fiyat = p_fiyat,
        urun_stok = p_stok,
        urun_birim = p_birim,
        urun_aciklama = p_aciklama
    WHERE urun_id = p_urun_id;
END $$

DELIMITER $$

CREATE PROCEDURE kd_UrunStokGuncelle (
    IN p_urun_id VARCHAR(64),
    IN p_yeni_stok FLOAT
)
BEGIN
    UPDATE kd_urunler
    SET urun_stok = p_yeni_stok
    WHERE urun_id = p_urun_id AND p_yeni_stok >= 0;
END $$

DELIMITER $$

CREATE PROCEDURE kd_UrunSil (
    IN p_urun_id VARCHAR(64)
)
BEGIN
    DELETE FROM kd_urunler WHERE urun_id = p_urun_id;
END $$

DELIMITER $$

CREATE PROCEDURE kd_UrunlerHepsi ()
BEGIN
    SELECT urun_id as ID, urun_ad as Adı, urun_kategori as Kategori, urun_fiyat as Fiyat, urun_stok as Stok, urun_birim as Birim, ortalama_puan as OrtalamaPuan, urun_aciklama as Açıklama
    FROM kd_urunler;
END $$

DELIMITER $$

CREATE PROCEDURE kd_UrunBul (
    IN p_filtre VARCHAR(250)
)
BEGIN
    SELECT urun_id as ID, urun_ad as Adı, urun_kategori as Kategori, urun_fiyat as Fiyat, urun_stok as Stok, urun_birim as Birim, ortalama_puan as OrtalamaPuan, urun_aciklama as Açıklama
    FROM kd_urunler
    WHERE urun_id LIKE CONCAT('%', p_filtre, '%') OR
          urun_ad LIKE CONCAT('%', p_filtre, '%') OR
          urun_kategori LIKE CONCAT('%', p_filtre, '%');
END $$

DELIMITER $$

CREATE PROCEDURE kd_UrunSiparisleriListele (
    IN p_urun_id VARCHAR(64)
)
BEGIN
    SELECT s.siparis_id AS SiparisID, m.musteri_ad, m.musteri_soyad, s.miktar, s.toplam_tutar, s.siparis_tarihi
    FROM kd_siparisler s
    JOIN kd_musteriler m ON s.musteri_id = m.musteri_id
    WHERE s.urun_id = p_urun_id
    ORDER BY s.siparis_tarihi DESC;
END $$

DELIMITER ;
 
 --
 
 DELIMITER $$
CREATE PROCEDURE kd_CalisanEkle (
    IN p_calisan_id VARCHAR(64),
    IN p_ad VARCHAR(64),
    IN p_soyad VARCHAR(64),
    IN p_pozisyon VARCHAR(100),
    IN p_ise_baslama_tarihi DATETIME,
    IN p_aktif_mi BOOLEAN
)
BEGIN
    INSERT INTO kd_calisanlar(calisan_id, calisan_ad, calisan_soyad, pozisyon, ise_baslama_tarihi, aktif_mi)
    VALUES (p_calisan_id, p_ad, p_soyad, p_pozisyon, p_ise_baslama_tarihi, p_aktif_mi);
END $$

DELIMITER $$

CREATE PROCEDURE kd_CalisanGuncelle (
    IN p_calisan_id VARCHAR(64),
    IN p_ad VARCHAR(64),
    IN p_soyad VARCHAR(64),
    IN p_pozisyon VARCHAR(100),
    IN p_ise_baslama_tarihi DATETIME,
    IN p_aktif_mi BOOLEAN
)
BEGIN
    UPDATE kd_calisanlar
    SET
        calisan_ad = p_ad,
        calisan_soyad = p_soyad,
        pozisyon = p_pozisyon,
        ise_baslama_tarihi = p_ise_baslama_tarihi,
        aktif_mi = p_aktif_mi
    WHERE calisan_id = p_calisan_id;
END $$

DELIMITER $$

CREATE PROCEDURE kd_CalisanSil (
    IN p_calisan_id VARCHAR(64)
)
BEGIN
    DELETE FROM kd_calisanlar WHERE calisan_id = p_calisan_id;
END $$

DELIMITER $$

CREATE PROCEDURE kd_CalisanlarHepsi ()
BEGIN
    SELECT calisan_id as ID, calisan_ad as Adı, calisan_soyad as Soyadı, pozisyon as Pozisyon, ise_baslama_tarihi as İşeBaşlama, aktif_mi as AktifMi
    FROM kd_calisanlar;
END $$

DELIMITER $$

CREATE PROCEDURE kd_CalisanBul (
    IN p_filtre VARCHAR(100)
)
BEGIN
    SELECT calisan_id as ID, calisan_ad as Adı, calisan_soyad as Soyadı, pozisyon as Pozisyon, aktif_mi as AktifMi
    FROM kd_calisanlar
    WHERE calisan_id LIKE CONCAT('%', p_filtre, '%') OR
          calisan_ad LIKE CONCAT('%', p_filtre, '%') OR
          calisan_soyad LIKE CONCAT('%', p_filtre, '%') OR
          pozisyon LIKE CONCAT('%', p_filtre, '%');
END $$

DELIMITER $$

CREATE PROCEDURE kd_CalisanAktiflikDurumuGuncelle (
    IN p_calisan_id VARCHAR(64),
    IN p_yeni_aktif_durum BOOLEAN
)
BEGIN
    UPDATE kd_calisanlar
    SET aktif_mi = p_yeni_aktif_durum
    WHERE calisan_id = p_calisan_id;
END $$

DELIMITER $$

CREATE PROCEDURE kd_CalisanSiparisleriListele(
    IN p_calisan_id VARCHAR(64)
)
BEGIN
    SELECT s.siparis_id, CONCAT(m.musteri_ad, ' ', m.musteri_soyad) AS Musteri, u.urun_ad, s.toplam_tutar, s.siparis_tarihi
    FROM kd_siparisler s
    JOIN kd_musteriler m ON s.musteri_id = m.musteri_id
    JOIN kd_urunler u ON s.urun_id = u.urun_id
    WHERE s.calisan_id = p_calisan_id
    ORDER BY s.siparis_tarihi DESC;
END $$

DELIMITER ;

--

DELIMITER $$
CREATE PROCEDURE kd_SiparisEkle (
    IN p_siparis_id VARCHAR(64),
    IN p_musteri_id VARCHAR(64),
    IN p_urun_id VARCHAR(64),
    IN p_calisan_id VARCHAR(64),
    IN p_miktar INT
)
BEGIN
    DECLARE v_urun_fiyat FLOAT;
    DECLARE v_toplam_tutar FLOAT;

    SELECT urun_fiyat INTO v_urun_fiyat FROM kd_urunler WHERE urun_id = p_urun_id;

    SET v_toplam_tutar = v_urun_fiyat * p_miktar;

    INSERT INTO kd_siparisler(siparis_id, musteri_id, urun_id, calisan_id, siparis_tarihi, miktar, satis_fiyati_birim, toplam_tutar)
    VALUES (p_siparis_id, p_musteri_id, p_urun_id, p_calisan_id, NOW(), p_miktar, v_urun_fiyat, v_toplam_tutar);
END $$

DELIMITER $$

CREATE PROCEDURE kd_SiparisGuncelle (
    IN p_siparis_id VARCHAR(64),
    IN p_musteri_id VARCHAR(64),
    IN p_urun_id VARCHAR(64),
    IN p_calisan_id VARCHAR(64),
    IN p_miktar INT,
    IN p_satis_fiyati_birim FLOAT,
    IN p_toplam_tutar FLOAT
)
BEGIN
    UPDATE kd_siparisler
    SET
        musteri_id = p_musteri_id,
        urun_id = p_urun_id,
        calisan_id = p_calisan_id,
        miktar = p_miktar,
        satis_fiyati_birim = p_satis_fiyati_birim,
        toplam_tutar = p_toplam_tutar
    WHERE siparis_id = p_siparis_id;
END $$

DELIMITER $$

CREATE PROCEDURE kd_SiparisSil (
    IN p_siparis_id VARCHAR(64)
)
BEGIN
    DELETE FROM kd_siparisler WHERE siparis_id = p_siparis_id;
END $$

DELIMITER $$

CREATE PROCEDURE kd_SiparislerHepsi ()
BEGIN
    SELECT s.siparis_id, CONCAT(m.musteri_ad, ' ', m.musteri_soyad) AS Musteri, u.urun_ad AS Urun, s.miktar, s.toplam_tutar, s.siparis_tarihi
    FROM kd_siparisler s
    JOIN kd_musteriler m ON s.musteri_id = m.musteri_id
    JOIN kd_urunler u ON s.urun_id = u.urun_id
    ORDER BY s.siparis_tarihi DESC;
END $$

DELIMITER $$

CREATE PROCEDURE kd_SiparisDetayGetir (
    IN p_siparis_id VARCHAR(64)
)
BEGIN
    SELECT
        s.siparis_id AS SiparisID,
        s.siparis_tarihi AS SiparisTarihi,
        s.miktar AS Miktar,
        s.satis_fiyati_birim AS SatisFiyatiBirim,
        s.toplam_tutar AS ToplamTutar,
        m.musteri_id AS MusteriID,
        CONCAT(m.musteri_ad, ' ', m.musteri_soyad) AS MusteriAdSoyad,
        m.musteri_email AS MusteriEmail,
        u.urun_id AS UrunID,
        u.urun_ad AS UrunAdi,
        u.urun_kategori AS UrunKategori,
        c.calisan_id AS CalisanID,
        CONCAT(c.calisan_ad, ' ', c.calisan_soyad) AS CalisanAdSoyad
    FROM kd_siparisler s
    JOIN kd_musteriler m ON s.musteri_id = m.musteri_id
    JOIN kd_urunler u ON s.urun_id = u.urun_id
    JOIN kd_calisanlar c ON s.calisan_id = c.calisan_id
    WHERE s.siparis_id = p_siparis_id;
END $$

DELIMITER ;

-- 

DELIMITER $$
CREATE PROCEDURE kd_DegerlendirmeEkle (
    IN p_degerlendirme_id VARCHAR(64),
    IN p_musteri_id VARCHAR(64),
    IN p_urun_id VARCHAR(64),
    IN p_siparis_id VARCHAR(64),
    IN p_puan INT,
    IN p_yorum TEXT
)
BEGIN
    INSERT INTO kd_degerlendirmeler(degerlendirme_id, musteri_id, urun_id, siparis_id, puan, yorum, degerlendirme_tarihi)
    VALUES (p_degerlendirme_id, p_musteri_id, p_urun_id, p_siparis_id, p_puan, p_yorum, NOW());
END $$

DELIMITER $$

CREATE PROCEDURE kd_DegerlendirmeGuncelle (
    IN p_degerlendirme_id VARCHAR(64),
    IN p_puan INT,
    IN p_yorum TEXT
)
BEGIN
    UPDATE kd_degerlendirmeler
    SET
        puan = p_puan,
        yorum = p_yorum,
        degerlendirme_tarihi = NOW()
    WHERE degerlendirme_id = p_degerlendirme_id;
END $$

DELIMITER $$

CREATE PROCEDURE kd_DegerlendirmeSil (
    IN p_degerlendirme_id VARCHAR(64)
)
BEGIN
    DELETE FROM kd_degerlendirmeler WHERE degerlendirme_id = p_degerlendirme_id;
END $$

DELIMITER $$

CREATE PROCEDURE kd_DegerlendirmelerHepsi ()
BEGIN
    SELECT d.degerlendirme_id, u.urun_ad, CONCAT(m.musteri_ad, ' ', m.musteri_soyad) AS Musteri, d.puan, d.yorum, d.degerlendirme_tarihi
    FROM kd_degerlendirmeler d
    JOIN kd_urunler u ON d.urun_id = u.urun_id
    JOIN kd_musteriler m ON d.musteri_id = m.musteri_id
    ORDER BY d.degerlendirme_tarihi DESC;
END $$

DELIMITER $$

CREATE PROCEDURE kd_UrunDegerlendirmeleriListele (
    IN p_urun_id VARCHAR(64)
)
BEGIN
    SELECT d.degerlendirme_id, CONCAT(m.musteri_ad, ' ', m.musteri_soyad) AS Musteri, d.puan, d.yorum, d.degerlendirme_tarihi
    FROM kd_degerlendirmeler d
    JOIN kd_musteriler m ON d.musteri_id = m.musteri_id
    WHERE d.urun_id = p_urun_id
    ORDER BY d.degerlendirme_tarihi DESC;
END $$

DELIMITER $$

CREATE PROCEDURE kd_MusteriDegerlendirmeleriListele (
    IN p_musteri_id VARCHAR(64)
)
BEGIN
    SELECT d.degerlendirme_id, u.urun_ad AS UrunAdi, d.puan, d.yorum, d.degerlendirme_tarihi
    FROM kd_degerlendirmeler d
    JOIN kd_urunler u ON d.urun_id = u.urun_id
    WHERE d.musteri_id = p_musteri_id
    ORDER BY d.degerlendirme_tarihi DESC;
END $$

DELIMITER ;

--

DELIMITER $$
CREATE PROCEDURE kd_OdemeEkle (
    IN p_odeme_id VARCHAR(64),
    IN p_musteri_id VARCHAR(64),
    IN p_siparis_id VARCHAR(64),
    IN p_odeme_tutari FLOAT,
    IN p_odeme_tur VARCHAR(25),
    IN p_odeme_aciklama VARCHAR(250)
)
BEGIN
    INSERT INTO kd_odemeler(odeme_id, musteri_id, siparis_id, odeme_tarihi, odeme_tutari, odeme_tur, odeme_aciklama)
    VALUES (p_odeme_id, p_musteri_id, p_siparis_id, NOW(), p_odeme_tutari, p_odeme_tur, p_odeme_aciklama);
END $$

DELIMITER $$

CREATE PROCEDURE kd_OdemeGuncelle (
    IN p_odeme_id VARCHAR(64),
    IN p_musteri_id VARCHAR(64),
    IN p_siparis_id VARCHAR(64),
    IN p_odeme_tutari FLOAT,
    IN p_odeme_tur VARCHAR(25),
    IN p_odeme_aciklama VARCHAR(250)
)
BEGIN
    UPDATE kd_odemeler
    SET
        musteri_id = p_musteri_id,
        siparis_id = p_siparis_id,
        odeme_tutari = p_odeme_tutari,
        odeme_tur = p_odeme_tur,
        odeme_aciklama = p_odeme_aciklama,
        odeme_tarihi = NOW()
    WHERE odeme_id = p_odeme_id;
END $$

DELIMITER $$

CREATE PROCEDURE kd_OdemeSil (
    IN p_odeme_id VARCHAR(64)
)
BEGIN
    DELETE FROM kd_odemeler WHERE odeme_id = p_odeme_id;
END $$

DELIMITER $$

CREATE PROCEDURE kd_OdemelerHepsi ()
BEGIN
    SELECT o.odeme_id, CONCAT(m.musteri_ad, ' ', m.musteri_soyad) AS Musteri, o.siparis_id, o.odeme_tutari, o.odeme_tur, o.odeme_tarihi, o.odeme_aciklama
    FROM kd_odemeler o
    JOIN kd_musteriler m ON o.musteri_id = m.musteri_id
    ORDER BY o.odeme_tarihi DESC;
END $$

DELIMITER $$

CREATE PROCEDURE kd_MusteriOdemeleriListele (
    IN p_musteri_id VARCHAR(64)
)
BEGIN
    SELECT odeme_id, siparis_id, odeme_tutari, odeme_tur, odeme_tarihi, odeme_aciklama
    FROM kd_odemeler
    WHERE musteri_id = p_musteri_id
    ORDER BY odeme_tarihi DESC;
END $$

DELIMITER $$

CREATE PROCEDURE kd_SiparisOdemeleriListele (
    IN p_siparis_id VARCHAR(64)
)
BEGIN
    SELECT odeme_id, odeme_tutari, odeme_tur, odeme_tarihi, odeme_aciklama
    FROM kd_odemeler
    WHERE siparis_id = p_siparis_id
    ORDER BY odeme_tarihi DESC;
END $$

DELIMITER $$

CREATE PROCEDURE kd_OdemeDetayGetir (
    IN p_odeme_id VARCHAR(64)
)
BEGIN
    SELECT
        o.odeme_id AS OdemeID,
        o.odeme_tarihi AS OdemeTarihi,
        o.odeme_tutari AS OdemeTutari,
        o.odeme_tur AS OdemeTuru,
        o.odeme_aciklama AS Aciklama,
        m.musteri_id AS MusteriID,
        CONCAT(m.musteri_ad, ' ', m.musteri_soyad) AS MusteriAdSoyad,
        o.siparis_id AS SiparisID
    FROM kd_odemeler o
    JOIN kd_musteriler m ON o.musteri_id = m.musteri_id
    WHERE o.odeme_id = p_odeme_id;
END $$

DELIMITER ;

--

DELIMITER $$
CREATE PROCEDURE kd_SiparisVeAnindaOdemeEkle (
    IN p_siparis_id VARCHAR(64),
    IN p_musteri_id VARCHAR(64),
    IN p_urun_id VARCHAR(64),
    IN p_calisan_id VARCHAR(64),
    IN p_miktar INT,
    IN p_odeme_id VARCHAR(64),
    IN p_odeme_tur VARCHAR(25),
    IN p_odeme_aciklama VARCHAR(250)
)
BEGIN
    DECLARE v_urun_fiyat FLOAT;
    DECLARE v_toplam_tutar FLOAT;
    DECLARE v_stok_yeterli BOOLEAN DEFAULT TRUE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT urun_fiyat INTO v_urun_fiyat FROM kd_urunler WHERE urun_id = p_urun_id;
    
    SELECT (urun_stok >= p_miktar) INTO v_stok_yeterli FROM kd_urunler WHERE urun_id = p_urun_id;

    IF v_stok_yeterli THEN
        SET v_toplam_tutar = v_urun_fiyat * p_miktar;

        INSERT INTO kd_siparisler(siparis_id, musteri_id, urun_id, calisan_id, siparis_tarihi, miktar, satis_fiyati_birim, toplam_tutar)
        VALUES (p_siparis_id, p_musteri_id, p_urun_id, p_calisan_id, NOW(), p_miktar, v_urun_fiyat, v_toplam_tutar);

        INSERT INTO kd_odemeler(odeme_id, musteri_id, siparis_id, odeme_tarihi, odeme_tutari, odeme_tur, odeme_aciklama)
        VALUES (p_odeme_id, p_musteri_id, p_siparis_id, NOW(), v_toplam_tutar, p_odeme_tur, p_odeme_aciklama);

        COMMIT;
    ELSE
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Yetersiz stok! İşlem geri alındı.';
    END IF;
END $$

DELIMITER $$

CREATE PROCEDURE kd_MusteriBakiyeHesapla (
    IN p_musteri_id VARCHAR(64)
)
BEGIN
    DECLARE v_toplam_borc FLOAT DEFAULT 0;
    DECLARE v_toplam_odeme FLOAT DEFAULT 0;

    SELECT SUM(COALESCE(toplam_tutar, 0)) INTO v_toplam_borc
    FROM kd_siparisler
    WHERE musteri_id = p_musteri_id;
    
    SELECT SUM(COALESCE(odeme_tutari, 0)) INTO v_toplam_odeme
    FROM kd_odemeler
    WHERE musteri_id = p_musteri_id;
    
    SET v_toplam_borc = IFNULL(v_toplam_borc, 0);
    SET v_toplam_odeme = IFNULL(v_toplam_odeme, 0);
    
    SELECT (v_toplam_odeme - v_toplam_borc) as Bakiye;
END $$

DELIMITER ;

--



DELIMITER $$
CREATE FUNCTION fn_UrunOrtalamaPuanHesapla (
    p_urun_id_param VARCHAR(64)
)
RETURNS FLOAT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_ortalama_puan FLOAT;

    SELECT AVG(puan) INTO v_ortalama_puan
    FROM kd_degerlendirmeler
    WHERE urun_id = p_urun_id_param;

    RETURN IFNULL(v_ortalama_puan, 0);
END $$

DELIMITER $$

CREATE FUNCTION fn_MusteriToplamHarcama (
    p_musteri_id_param VARCHAR(64)
)
RETURNS FLOAT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_toplam_harcama FLOAT;

    SELECT SUM(toplam_tutar) INTO v_toplam_harcama
    FROM kd_siparisler
    WHERE musteri_id = p_musteri_id_param;

    RETURN IFNULL(v_toplam_harcama, 0);
END $$

DELIMITER ;

--


DELIMITER //
CREATE TRIGGER trg_SiparisEklemedenOnceStokKontrol
BEFORE INSERT ON kd_siparisler
FOR EACH ROW
BEGIN
    DECLARE v_mevcut_stok FLOAT;
    DECLARE v_hata_mesaji VARCHAR(255);

    SELECT urun_stok INTO v_mevcut_stok FROM kd_urunler WHERE urun_id = NEW.urun_id;

    IF v_mevcut_stok < NEW.miktar THEN
        SET v_hata_mesaji = CONCAT('Yetersiz stok! ', NEW.urun_id, ' ID''li üründen sadece ', v_mevcut_stok, ' adet bulunmaktadır. İstenen miktar: ', NEW.miktar);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_hata_mesaji;
    END IF;
END; //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_SiparisEklendiktenSonraStokAzalt
AFTER INSERT ON kd_siparisler
FOR EACH ROW
BEGIN
    UPDATE kd_urunler
    SET urun_stok = urun_stok - NEW.miktar
    WHERE urun_id = NEW.urun_id;
END; //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_SiparisSilindiktenSonraStokGeriEkle
AFTER DELETE ON kd_siparisler
FOR EACH ROW
BEGIN
    UPDATE kd_urunler
    SET urun_stok = urun_stok + OLD.miktar
    WHERE urun_id = OLD.urun_id;
END; //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_DegerlendirmeKaydiSonrasiUrunOrtalamaPuanGuncelle
AFTER INSERT ON kd_degerlendirmeler
FOR EACH ROW
BEGIN
    DECLARE v_yeni_ortalama_puan FLOAT;
    SET v_yeni_ortalama_puan = fn_UrunOrtalamaPuanHesapla(NEW.urun_id);
    UPDATE kd_urunler SET ortalama_puan = v_yeni_ortalama_puan WHERE urun_id = NEW.urun_id;
END; //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_DegerlendirmeGuncellemeSonrasiUrunOrtalamaPuanGuncelle
AFTER UPDATE ON kd_degerlendirmeler
FOR EACH ROW
BEGIN
    DECLARE v_yeni_ortalama_puan_new FLOAT;

    IF OLD.urun_id != NEW.urun_id THEN
        UPDATE kd_urunler SET ortalama_puan = fn_UrunOrtalamaPuanHesapla(OLD.urun_id) WHERE urun_id = OLD.urun_id;
    END IF;

    SET v_yeni_ortalama_puan_new = fn_UrunOrtalamaPuanHesapla(NEW.urun_id);
    UPDATE kd_urunler SET ortalama_puan = v_yeni_ortalama_puan_new WHERE urun_id = NEW.urun_id;
END; //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_DegerlendirmeSilmeSonrasiUrunOrtalamaPuanGuncelle
AFTER DELETE ON kd_degerlendirmeler
FOR EACH ROW
BEGIN
    UPDATE kd_urunler SET ortalama_puan = fn_UrunOrtalamaPuanHesapla(OLD.urun_id) WHERE urun_id = OLD.urun_id;
END; //
DELIMITER ;