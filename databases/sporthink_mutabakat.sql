-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Anamakine: 127.0.0.1:3306
-- Üretim Zamanı: 24 Nis 2026, 13:54:41
-- Sunucu sürümü: 9.1.0
-- PHP Sürümü: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Veritabanı: `sporthink_mutabakat`
--

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `amazon_islemler`
--

DROP TABLE IF EXISTS `amazon_islemler`;
CREATE TABLE IF NOT EXISTS `amazon_islemler` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `tarih` date DEFAULT NULL,
  `islem_durumu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `islem_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Siparis Odemesi, Kargo, Para Iadesi vb.',
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `urun_detaylari` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `toplam_urun_fiyatlari` decimal(20,8) DEFAULT NULL,
  `toplam_promosyon_indirimleri` decimal(20,8) DEFAULT NULL,
  `amazon_ucretleri` decimal(20,8) DEFAULT NULL,
  `diger` decimal(20,8) DEFAULT NULL,
  `toplam_try` decimal(20,8) DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_amz_siparis` (`siparis_no`),
  KEY `idx_amz_tarih` (`tarih`),
  KEY `idx_amz_tip` (`islem_tipi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Amazon islem listesi';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `flo_fatura_detay`
--

DROP TABLE IF EXISTS `flo_fatura_detay`;
CREATE TABLE IF NOT EXISTS `flo_fatura_detay` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `fatura_id` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_tarihi` date DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `islem` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'penalty, commission vb.',
  `islem_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Ceza, Komisyon vb.',
  `islem_zamani` datetime DEFAULT NULL,
  `miktar` decimal(20,8) DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_flo_siparis` (`siparis_no`),
  KEY `idx_flo_tarih` (`fatura_tarihi`),
  KEY `idx_flo_islem` (`islem_tipi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Flo fatura detay';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `flo_kargo_desi_fiyatlari`
--

DROP TABLE IF EXISTS `flo_kargo_desi_fiyatlari`;
CREATE TABLE IF NOT EXISTS `flo_kargo_desi_fiyatlari` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `desi` decimal(20,8) NOT NULL,
  `hepsijet` decimal(20,8) DEFAULT NULL,
  `aras` decimal(20,8) DEFAULT NULL,
  `gecerlilik_tarihi` date NOT NULL DEFAULT (curdate()),
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_flo_desi` (`desi`),
  KEY `idx_flo_tarih` (`gecerlilik_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Flo kargo desi fiyatlari';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `hepsiburada_hakedis`
--

DROP TABLE IF EXISTS `hepsiburada_hakedis`;
CREATE TABLE IF NOT EXISTS `hepsiburada_hakedis` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `hakedis_donemi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `ongorulen_odeme_tarihi` date DEFAULT NULL,
  `durum` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `odeme_tarihi` date DEFAULT NULL,
  `vade_tarihi` date DEFAULT NULL,
  `kayit_tarihi` date DEFAULT NULL,
  `kayit_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kayit_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `ceza_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kayit_turu` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Gelir / Gider',
  `kayit_sinifi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `po_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Hepsiburada PO = siparis no',
  `siparis_tarihi` datetime DEFAULT NULL,
  `urun_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'SKU',
  `urun_adi` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `urun_adedi` smallint DEFAULT NULL,
  `birim_tutar` decimal(20,8) DEFAULT NULL,
  `liste_fiyati` decimal(20,8) DEFAULT NULL,
  `tutar` decimal(20,8) DEFAULT NULL,
  `para_birimi` varchar(10) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `vade_suresi` int DEFAULT NULL,
  `paket_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_hb_siparis` (`siparis_no`),
  KEY `idx_hb_po` (`po_no`),
  KEY `idx_hb_tarih` (`kayit_tarihi`),
  KEY `idx_hb_tur` (`kayit_turu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Hepsiburada hakedis listesi';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `hepsiburada_kargo_desi_fiyatlari`
--

DROP TABLE IF EXISTS `hepsiburada_kargo_desi_fiyatlari`;
CREATE TABLE IF NOT EXISTS `hepsiburada_kargo_desi_fiyatlari` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `desi` decimal(20,8) NOT NULL,
  `hepsijet` decimal(20,8) DEFAULT NULL,
  `aras_kargo` decimal(20,8) DEFAULT NULL,
  `mng_kargo` decimal(20,8) DEFAULT NULL,
  `yurtici_kargo` decimal(20,8) DEFAULT NULL,
  `surat_kargo` decimal(20,8) DEFAULT NULL,
  `sendeo` decimal(20,8) DEFAULT NULL,
  `ptt_kargo` decimal(20,8) DEFAULT NULL,
  `hepsijet_xl` decimal(20,8) DEFAULT NULL,
  `horoz_lojistik` decimal(20,8) DEFAULT NULL,
  `ceva_lojistik` decimal(20,8) DEFAULT NULL,
  `borusan_lojistik` decimal(20,8) DEFAULT NULL,
  `gecerlilik_tarihi` date NOT NULL DEFAULT (curdate()),
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_hb_desi` (`desi`),
  KEY `idx_hb_tarih` (`gecerlilik_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Hepsiburada kargo desi fiyatlari';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `karlilik_ozeti`
--

DROP TABLE IF EXISTS `karlilik_ozeti`;
CREATE TABLE IF NOT EXISTS `karlilik_ozeti` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `siparis_id` int UNSIGNED NOT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `pazaryeri_siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `barkod` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `urun_adi` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `pazaryeri` enum('Trendyol','Hepsiburada','Flo','N11','Pazarama','LCW','Amazon') COLLATE utf8mb4_turkish_ci NOT NULL,
  `siparis_durumu` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL,
  `siparis_tarihi` datetime NOT NULL,
  `ulke` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kdv_orani` decimal(20,8) DEFAULT NULL,
  `kategori` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_adeti` smallint DEFAULT NULL,
  `birim_fiyat` decimal(20,8) DEFAULT NULL,
  `siparis_toplam_tutari` decimal(20,8) DEFAULT NULL,
  `pazaryeri_fiyati` decimal(20,8) DEFAULT NULL,
  `satis_adeti` smallint DEFAULT NULL,
  `satis_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `satis_tutari` decimal(20,8) DEFAULT NULL,
  `satis_iade_adedi` smallint DEFAULT NULL,
  `satis_iade_tutari` decimal(20,8) DEFAULT NULL,
  `iade_iptal_adedi` smallint DEFAULT NULL,
  `iade_iptal_tutari` decimal(20,8) DEFAULT NULL,
  `tahmini_desi` decimal(20,8) DEFAULT NULL,
  `hesaplanan_siparis_desisi` decimal(20,8) DEFAULT NULL,
  `hesaplanan_siparis_desi_tutari` decimal(20,8) DEFAULT NULL,
  `faturalanan_desi_tutari` decimal(20,8) DEFAULT NULL,
  `faturalanan_desi` decimal(20,8) DEFAULT NULL,
  `hesaplanan_komisyon_tutari` decimal(20,8) DEFAULT NULL,
  `faturalanan_komisyon_tutari` decimal(20,8) DEFAULT NULL,
  `faturalanan_iade_komisyonu` decimal(20,8) DEFAULT NULL,
  `urun_maliyeti` decimal(20,8) DEFAULT NULL,
  `kargo_maliyeti` decimal(20,8) DEFAULT NULL,
  `satis_kargosu` decimal(20,8) DEFAULT NULL,
  `iade_kargosu` decimal(20,8) DEFAULT NULL,
  `stopaj` decimal(20,8) DEFAULT NULL,
  `stopaj_iadesi` decimal(20,8) DEFAULT NULL,
  `tedarik_edememe` decimal(20,8) DEFAULT NULL,
  `gecikme_cezasi` decimal(20,8) DEFAULT NULL,
  `yanlis_urun` decimal(20,8) DEFAULT NULL,
  `kusurlu_urun` decimal(20,8) DEFAULT NULL,
  `eksik_urun` decimal(20,8) DEFAULT NULL,
  `kupon` decimal(20,8) DEFAULT NULL,
  `kampanya_indirimi` decimal(20,8) DEFAULT NULL,
  `pazarlama_hizmet_bedeli` decimal(20,8) DEFAULT NULL,
  `platform_hizmet_bedeli` decimal(20,8) DEFAULT NULL,
  `reklam_gideri` decimal(20,8) DEFAULT NULL,
  `diger_kesintiler` decimal(20,8) DEFAULT NULL,
  `net_gelir` decimal(20,8) DEFAULT NULL,
  `net_kar` decimal(20,8) DEFAULT NULL,
  `kar_marji` decimal(20,8) DEFAULT NULL,
  `zarar_mi` tinyint(1) NOT NULL DEFAULT '0',
  `mutabakat_durumu` enum('eslesdi','fark_var','manuel_inceleme','beklemede') COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `mukrerrer_mi` tinyint(1) NOT NULL DEFAULT '0',
  `fark_var_mi` tinyint(1) NOT NULL DEFAULT '0',
  `iade_komisyon_dogru_mu` tinyint(1) DEFAULT NULL,
  `odeme_farki` decimal(20,8) DEFAULT NULL,
  `son_hesaplama_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tek_siparis_ozet` (`siparis_id`),
  KEY `idx_ozet_pazaryeri` (`pazaryeri`),
  KEY `idx_ozet_durum` (`siparis_durumu`),
  KEY `idx_ozet_zarar` (`zarar_mi`),
  KEY `idx_ozet_tarih` (`siparis_tarihi`),
  KEY `idx_ozet_barkod` (`barkod`),
  KEY `idx_ozet_mutabakat` (`mutabakat_durumu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Son tablo — karlilik ozeti ve mutabakat';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `lcw_kargo_desi_fiyatlari`
--

DROP TABLE IF EXISTS `lcw_kargo_desi_fiyatlari`;
CREATE TABLE IF NOT EXISTS `lcw_kargo_desi_fiyatlari` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `desi` decimal(20,8) NOT NULL,
  `aras_kargo` decimal(20,8) DEFAULT NULL,
  `hepsijet` decimal(20,8) DEFAULT NULL,
  `kargoist` decimal(20,8) DEFAULT NULL,
  `surat_kargo` decimal(20,8) DEFAULT NULL,
  `yurtici_kargo` decimal(20,8) DEFAULT NULL,
  `gecerlilik_tarihi` date NOT NULL DEFAULT (curdate()),
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_lcw_desi` (`desi`),
  KEY `idx_lcw_tarih` (`gecerlilik_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='LCW kargo desi fiyatlari';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `lcw_kargo_faturalari`
--

DROP TABLE IF EXISTS `lcw_kargo_faturalari`;
CREATE TABLE IF NOT EXISTS `lcw_kargo_faturalari` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `islem_kayit_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `satici` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `cari_kod` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `paket_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kargo_firmasi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `desi` decimal(20,8) DEFAULT NULL,
  `islem_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Kargo Maliyeti / Iade Kargo Maliyeti',
  `siparis_tarihi` datetime DEFAULT NULL,
  `sevk_tarihi` datetime DEFAULT NULL,
  `teslim_tarihi` datetime DEFAULT NULL,
  `vade_gunu` int DEFAULT NULL,
  `vade_tarihi` datetime DEFAULT NULL,
  `lcw_kargo_hakedis` decimal(20,8) DEFAULT NULL,
  `fatura_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_tarihi` date DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_lcw_kar_siparis` (`siparis_no`),
  KEY `idx_lcw_kar_tarih` (`fatura_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='LCW kargo faturalari';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `lcw_komisyon_faturalari`
--

DROP TABLE IF EXISTS `lcw_komisyon_faturalari`;
CREATE TABLE IF NOT EXISTS `lcw_komisyon_faturalari` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `islem_kayit_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `satici` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `cari_kod` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `paket_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `barkod` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `marka` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `urun_kategori` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `urun_adi` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `islem_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_tarihi` datetime DEFAULT NULL,
  `islem_tarihi` datetime DEFAULT NULL,
  `vade_gunu` int DEFAULT NULL,
  `vade_tarihi` datetime DEFAULT NULL,
  `hakedis_haftasi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `not_alani` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `muhasebe_gunluk_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `pesin_urun_tutari` decimal(20,8) DEFAULT NULL,
  `taksitli_urun_tutari` decimal(20,8) DEFAULT NULL,
  `lcw_taksit_farki` decimal(20,8) DEFAULT NULL,
  `lcwaikiki_sponsorlugu` decimal(20,8) DEFAULT NULL,
  `satici_sponsorlugu` decimal(20,8) DEFAULT NULL,
  `toplam_indirim` decimal(20,8) DEFAULT NULL,
  `indirim_aciklamasi` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `satis_tutari` decimal(20,8) DEFAULT NULL,
  `komisyon_orani` decimal(20,8) DEFAULT NULL,
  `lcw_komisyon_hakedis` decimal(20,8) DEFAULT NULL,
  `lcw_toplam_hakedis` decimal(20,8) DEFAULT NULL,
  `satici_hakedis` decimal(20,8) DEFAULT NULL,
  `fatura_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_tarihi` date DEFAULT NULL,
  `yan_not` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `mevzuat_pesin_tutar` decimal(20,8) DEFAULT NULL,
  `mevzuat_taksitli_tutar` decimal(20,8) DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_lcw_kom_siparis` (`siparis_no`),
  KEY `idx_lcw_kom_barkod` (`barkod`),
  KEY `idx_lcw_kom_tarih` (`fatura_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='LCW komisyon faturalari';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `mutabakat`
--

DROP TABLE IF EXISTS `mutabakat`;
CREATE TABLE IF NOT EXISTS `mutabakat` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `siparis_id` int UNSIGNED NOT NULL,
  `pazaryeri` enum('Trendyol','Hepsiburada','Flo','N11','Pazarama','LCW','Amazon') COLLATE utf8mb4_turkish_ci NOT NULL,
  `beklenen_odeme` decimal(20,8) DEFAULT NULL,
  `beklenen_komisyon` decimal(20,8) DEFAULT NULL,
  `beklenen_kargo` decimal(20,8) DEFAULT NULL,
  `beklenen_stopaj` decimal(20,8) DEFAULT NULL,
  `gerceklesen_odeme` decimal(20,8) DEFAULT NULL,
  `faturalanan_komisyon` decimal(20,8) DEFAULT NULL,
  `faturalanan_satis_kargosu` decimal(20,8) DEFAULT NULL,
  `faturalanan_iade_kargosu` decimal(20,8) DEFAULT NULL,
  `faturalanan_stopaj` decimal(20,8) DEFAULT NULL,
  `odeme_farki` decimal(20,8) DEFAULT NULL,
  `komisyon_farki` decimal(20,8) DEFAULT NULL,
  `kargo_farki` decimal(20,8) DEFAULT NULL,
  `mutabakat_durumu` enum('eslesdi','fark_var','manuel_inceleme','beklemede') COLLATE utf8mb4_turkish_ci NOT NULL DEFAULT 'beklemede',
  `mukrerrer_mi` tinyint(1) NOT NULL DEFAULT '0',
  `fark_var_mi` tinyint(1) NOT NULL DEFAULT '0',
  `iade_komisyon_dogru_mu` tinyint(1) DEFAULT NULL,
  `guven_skoru` decimal(20,8) DEFAULT NULL,
  `notlar` text COLLATE utf8mb4_turkish_ci,
  `mutabakat_tarihi` datetime DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `guncelleme_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tek_siparis_mutabakat` (`siparis_id`),
  KEY `idx_mutabakat_durumu` (`mutabakat_durumu`),
  KEY `idx_mutabakat_pazaryeri` (`pazaryeri`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Mutabakat ve odeme takibi';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `n11_kargo`
--

DROP TABLE IF EXISTS `n11_kargo`;
CREATE TABLE IF NOT EXISTS `n11_kargo` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `siparis_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kampanya_numarasi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `musteri` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `islem_tarihi` datetime DEFAULT NULL,
  `islem_turu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kargo_sirketi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `tl_desi_kg` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT '50 TL / 5 Desi veya kg formatinda',
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_n11_kar_siparis` (`siparis_kodu`),
  KEY `idx_n11_kar_tarih` (`islem_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='N11 kargo listesi';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `n11_kargo_desi_fiyatlari`
--

DROP TABLE IF EXISTS `n11_kargo_desi_fiyatlari`;
CREATE TABLE IF NOT EXISTS `n11_kargo_desi_fiyatlari` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `desi` decimal(20,8) NOT NULL,
  `aras_kargo` decimal(20,8) DEFAULT NULL,
  `ptt_kargo` decimal(20,8) DEFAULT NULL,
  `yurtici_kargo` decimal(20,8) DEFAULT NULL,
  `surat_kargo` decimal(20,8) DEFAULT NULL,
  `sendeo_kargo` decimal(20,8) DEFAULT NULL,
  `gecerlilik_tarihi` date NOT NULL DEFAULT (curdate()),
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_n11_desi` (`desi`),
  KEY `idx_n11_tarih` (`gecerlilik_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='N11 kargo desi fiyatlari';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `n11_komisyon_faturalari`
--

DROP TABLE IF EXISTS `n11_komisyon_faturalari`;
CREATE TABLE IF NOT EXISTS `n11_komisyon_faturalari` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `fatura_turu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_tarihi` date DEFAULT NULL,
  `satici_id` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `magaza_adi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_kalem_id` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `islem_tipi_tanimi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_tamamlanma_tarihi` date DEFAULT NULL,
  `siparis_tutari` decimal(20,8) DEFAULT NULL,
  `komisyon_orani` decimal(20,8) DEFAULT NULL,
  `komisyon_bedeli` decimal(20,8) DEFAULT NULL,
  `pazarlama_hizmet_bedeli` decimal(20,8) DEFAULT NULL,
  `pazaryeri_hizmet_bedeli` decimal(20,8) DEFAULT NULL,
  `vade_farki_yansitmasi` decimal(20,8) DEFAULT NULL,
  `sozlesme_ceza_bedeli` decimal(20,8) DEFAULT NULL,
  `reklam_bedeli` decimal(20,8) DEFAULT NULL,
  `k_fatura_numarasi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `satici_hakedis_tutari` decimal(20,8) DEFAULT NULL,
  `hakedis_transfer_tarihi` date DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_n11_kom_siparis` (`siparis_no`),
  KEY `idx_n11_kom_tarih` (`fatura_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='N11 komisyon faturalari';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `pazarama_ceza`
--

DROP TABLE IF EXISTS `pazarama_ceza`;
CREATE TABLE IF NOT EXISTS `pazarama_ceza` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `siparis_tarihi` date DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `urun_adi` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `urun_adet` smallint DEFAULT NULL,
  `ceza_ana_kategorisi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `indirimli_birim_fiyat` decimal(20,8) DEFAULT NULL,
  `toplam_fiyat` decimal(20,8) DEFAULT NULL,
  `ceza_tutari` decimal(20,8) DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pzr_cez_siparis` (`siparis_no`),
  KEY `idx_pzr_cez_tarih` (`siparis_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Pazarama ceza listesi';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `pazarama_fatura_ozet`
--

DROP TABLE IF EXISTS `pazarama_fatura_ozet`;
CREATE TABLE IF NOT EXISTS `pazarama_fatura_ozet` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `bayi_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `firma_adi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_tarihi` date DEFAULT NULL,
  `donem` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `vkn` varchar(20) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `komisyon_tutar` decimal(20,8) DEFAULT NULL,
  `kargo_tutari` decimal(20,8) DEFAULT NULL,
  `entegrasyon_bedeli` decimal(20,8) DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pzr_ozet_fatura` (`fatura_no`),
  KEY `idx_pzr_ozet_tarih` (`fatura_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Pazarama fatura ozeti';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `pazarama_kargo_desi_fiyatlari`
--

DROP TABLE IF EXISTS `pazarama_kargo_desi_fiyatlari`;
CREATE TABLE IF NOT EXISTS `pazarama_kargo_desi_fiyatlari` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `desi` decimal(20,8) NOT NULL,
  `tutar_kdvsiz` decimal(20,8) DEFAULT NULL,
  `gecerlilik_tarihi` date NOT NULL DEFAULT (curdate()),
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pzr_desi` (`desi`),
  KEY `idx_pzr_tarih` (`gecerlilik_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Pazarama kargo desi fiyatlari';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `pazarama_kargo_detay`
--

DROP TABLE IF EXISTS `pazarama_kargo_detay`;
CREATE TABLE IF NOT EXISTS `pazarama_kargo_detay` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `fatura_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_tarihi` date DEFAULT NULL,
  `fatura_turu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kargo_firmasi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `bayi_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_durumu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `donem` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `desi` decimal(20,8) DEFAULT NULL,
  `satici_borcu` decimal(20,8) DEFAULT NULL,
  `gonderi_numarasi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pzr_kar_siparis` (`siparis_no`),
  KEY `idx_pzr_kar_tarih` (`fatura_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Pazarama kargo detay';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `pazarama_komisyon_detay`
--

DROP TABLE IF EXISTS `pazarama_komisyon_detay`;
CREATE TABLE IF NOT EXISTS `pazarama_komisyon_detay` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `fatura_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_tarihi` date DEFAULT NULL,
  `fatura_turu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `bayi_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `satici_adi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_durumu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_tarihi` date DEFAULT NULL,
  `karsi_islem_id` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_tutari` decimal(20,8) DEFAULT NULL,
  `satici_komisyon_tutari` decimal(20,8) DEFAULT NULL,
  `entegrasyon_bedeli` decimal(20,8) DEFAULT NULL,
  `etm_tutari` decimal(20,8) DEFAULT NULL,
  `etm_komisyonu` decimal(20,8) DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pzr_kom_siparis` (`siparis_no`),
  KEY `idx_pzr_kom_tarih` (`fatura_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Pazarama komisyon detay';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `siparisler`
--

DROP TABLE IF EXISTS `siparisler`;
CREATE TABLE IF NOT EXISTS `siparisler` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `pazaryeri_siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `pazaryeri` enum('Trendyol','Hepsiburada','Flo','N11','Pazarama','LCW','Amazon') COLLATE utf8mb4_turkish_ci NOT NULL,
  `durum` enum('teslim_edildi','iade','iptal','beklemede') COLLATE utf8mb4_turkish_ci NOT NULL DEFAULT 'beklemede',
  `barkod` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `urun_adi` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `marka` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kategori` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `adet` smallint NOT NULL DEFAULT '1',
  `birim_fiyat` decimal(20,8) NOT NULL,
  `kdv_orani` decimal(20,8) NOT NULL DEFAULT '20.00000000',
  `toplam_tutar` decimal(20,8) NOT NULL,
  `pazaryeri_fiyati` decimal(20,8) DEFAULT NULL,
  `siparis_tarihi` datetime NOT NULL,
  `kargo_gonderim_tarihi` datetime DEFAULT NULL,
  `kaynak_magaza` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `ulke` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `iade_iptal_turu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `iade_iptal_adedi` smallint DEFAULT NULL,
  `iade_iptal_tutari` decimal(20,8) DEFAULT NULL,
  `satis_adeti` smallint DEFAULT NULL,
  `satis_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `satis_tutari` decimal(20,8) DEFAULT NULL,
  `satis_iade_adedi` smallint DEFAULT NULL,
  `satis_iade_tutari` decimal(20,8) DEFAULT NULL,
  `tahmini_desi` decimal(20,8) DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `guncelleme_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tek_pazaryeri_siparis` (`pazaryeri`,`pazaryeri_siparis_no`),
  KEY `idx_siparis_pazaryeri` (`pazaryeri`),
  KEY `idx_siparis_durum` (`durum`),
  KEY `idx_siparis_barkod` (`barkod`),
  KEY `idx_siparis_tarihi` (`siparis_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Ana siparis tablosu';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `siparis_kalemleri`
--

DROP TABLE IF EXISTS `siparis_kalemleri`;
CREATE TABLE IF NOT EXISTS `siparis_kalemleri` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `siparis_id` int UNSIGNED NOT NULL,
  `barkod` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `urun_adi` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `adet` smallint NOT NULL DEFAULT '1',
  `birim_fiyat` decimal(20,8) NOT NULL,
  `urun_maliyeti` decimal(20,8) NOT NULL DEFAULT '0.00000000',
  `satis_adeti` smallint NOT NULL DEFAULT '0',
  `satis_tutari` decimal(20,8) NOT NULL DEFAULT '0.00000000',
  `iade_adeti` smallint NOT NULL DEFAULT '0',
  `iade_tutari` decimal(20,8) NOT NULL DEFAULT '0.00000000',
  `tahmini_desi` decimal(20,8) DEFAULT NULL,
  `faturalanan_desi` decimal(20,8) DEFAULT NULL,
  `hesaplanan_desi_tutari` decimal(20,8) DEFAULT NULL,
  `hesaplanan_satis_komisyonu` decimal(20,8) DEFAULT NULL,
  `hesaplanan_iade_komisyonu` decimal(20,8) DEFAULT NULL,
  `hesaplanan_kargo_tutari` decimal(20,8) DEFAULT NULL,
  `net_gelir` decimal(20,8) DEFAULT NULL,
  `net_kar` decimal(20,8) DEFAULT NULL,
  `kar_marji` decimal(20,8) DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `guncelleme_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_kalem_siparis` (`siparis_id`),
  KEY `idx_kalem_barkod` (`barkod`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Siparis satir detayi';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `trendyol_ceza_faturalari`
--

DROP TABLE IF EXISTS `trendyol_ceza_faturalari`;
CREATE TABLE IF NOT EXISTS `trendyol_ceza_faturalari` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `fatura_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_turu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_tarihi` date DEFAULT NULL,
  `satici_id` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `satici_ismi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `iade_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'kusurlu urun, yanlis urun, termin gecikme',
  `urun_adedi` smallint DEFAULT NULL,
  `urun_tutari` decimal(20,8) DEFAULT NULL,
  `kesilen_bedel` decimal(20,8) DEFAULT NULL,
  `gonderi_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_tarihi` datetime DEFAULT NULL,
  `kargo_cikis_tarihi` datetime DEFAULT NULL,
  `termin` int DEFAULT NULL,
  `geciken_urun_adedi` smallint DEFAULT NULL,
  `geciken_urun_tutari` decimal(20,8) DEFAULT NULL,
  `not_alani` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ty_cez_siparis` (`siparis_no`),
  KEY `idx_ty_cez_tip` (`fatura_tipi`),
  KEY `idx_ty_cez_tarih` (`fatura_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Trendyol ceza faturalari (kusurlu, yanlis urun, termin gecikme)';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `trendyol_iptal_listesi`
--

DROP TABLE IF EXISTS `trendyol_iptal_listesi`;
CREATE TABLE IF NOT EXISTS `trendyol_iptal_listesi` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `barkod` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `paket_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_tarihi` datetime DEFAULT NULL,
  `iptal_tarihi` datetime DEFAULT NULL,
  `kargo_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `alici` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `urun_adi` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `marka` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `stok_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `adet` smallint DEFAULT NULL,
  `birim_fiyati` decimal(20,8) DEFAULT NULL,
  `iptal_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `iptal_nedeni` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ty_ipt_siparis` (`siparis_no`),
  KEY `idx_ty_ipt_barkod` (`barkod`),
  KEY `idx_ty_ipt_tarih` (`iptal_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Trendyol iptal listesi';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `trendyol_islem_bedelleri`
--

DROP TABLE IF EXISTS `trendyol_islem_bedelleri`;
CREATE TABLE IF NOT EXISTS `trendyol_islem_bedelleri` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `fatura_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_turu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Platform Hizmet Bedeli, Uluslararasi Hizmet Bedeli',
  `fatura_tarihi` date DEFAULT NULL,
  `satici_id` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `ek_ucret` decimal(20,8) DEFAULT NULL,
  `satici_ismi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `gonderi_iade` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `gonderi_iade_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kargo_firmasi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_tarihi` datetime DEFAULT NULL,
  `sevk_tarihi` datetime DEFAULT NULL,
  `siparis_tutari` decimal(20,8) DEFAULT NULL,
  `islem_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `vade_tarihi` datetime DEFAULT NULL,
  `affiliate` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `aciklama` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ty_isl_siparis` (`siparis_no`),
  KEY `idx_ty_isl_tarih` (`fatura_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Trendyol platform ve uluslararasi islem bedelleri';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `trendyol_kargo_desi_fiyatlari`
--

DROP TABLE IF EXISTS `trendyol_kargo_desi_fiyatlari`;
CREATE TABLE IF NOT EXISTS `trendyol_kargo_desi_fiyatlari` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `desi` decimal(20,8) NOT NULL,
  `aras` decimal(20,8) DEFAULT NULL,
  `mng` decimal(20,8) DEFAULT NULL,
  `ptt` decimal(20,8) DEFAULT NULL,
  `sendeo` decimal(20,8) DEFAULT NULL,
  `surat` decimal(20,8) DEFAULT NULL,
  `tex` decimal(20,8) DEFAULT NULL,
  `yurtici` decimal(20,8) DEFAULT NULL,
  `borusan` decimal(20,8) DEFAULT NULL,
  `ceva` decimal(20,8) DEFAULT NULL,
  `horoz` decimal(20,8) DEFAULT NULL,
  `gecerlilik_tarihi` date NOT NULL DEFAULT (curdate()),
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_tdy_desi` (`desi`),
  KEY `idx_tdy_tarih` (`gecerlilik_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Trendyol kargo desi fiyatlari';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `trendyol_kargo_faturalari`
--

DROP TABLE IF EXISTS `trendyol_kargo_faturalari`;
CREATE TABLE IF NOT EXISTS `trendyol_kargo_faturalari` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `fatura_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_turu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_tarihi` date DEFAULT NULL,
  `satici_id` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `gonderi_ucreti` decimal(20,8) DEFAULT NULL,
  `desi` decimal(20,8) DEFAULT NULL,
  `satici_ismi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `gonderi_iade` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `gonderi_iade_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kargo_firmasi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_tarihi` datetime DEFAULT NULL,
  `sevk_tarihi` datetime DEFAULT NULL,
  `siparis_tutari` decimal(20,8) DEFAULT NULL,
  `min_kampanya_baremi` decimal(20,8) DEFAULT NULL,
  `urun_adedi` smallint DEFAULT NULL,
  `butik_id` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `aciklama` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ty_kar_siparis` (`siparis_no`),
  KEY `idx_ty_kar_tarih` (`fatura_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Trendyol kargo faturalari';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `trendyol_komisyon_faturalari`
--

DROP TABLE IF EXISTS `trendyol_komisyon_faturalari`;
CREATE TABLE IF NOT EXISTS `trendyol_komisyon_faturalari` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `fatura_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_turu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_tarihi` date DEFAULT NULL,
  `satici_id` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kayit_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `islem_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_tarihi` datetime DEFAULT NULL,
  `ulke` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `islem_tarihi` datetime DEFAULT NULL,
  `satici` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `satici_cari_adi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `urun_adi` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `barkod` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `komisyon_orani` decimal(20,8) DEFAULT NULL,
  `trendyol_hakedis` decimal(20,8) DEFAULT NULL,
  `satici_hakedis` decimal(20,8) DEFAULT NULL,
  `vade_suresi` int DEFAULT NULL,
  `teslim_tarihi` datetime DEFAULT NULL,
  `vade_tarihi` datetime DEFAULT NULL,
  `toplam_tutar` decimal(20,8) DEFAULT NULL,
  `musteri_ad` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `musteri_soyad` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `magaza_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `magaza_adi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `magaza_adresi` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ty_kom_siparis` (`siparis_no`),
  KEY `idx_ty_kom_barkod` (`barkod`),
  KEY `idx_ty_kom_tarih` (`fatura_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Trendyol komisyon faturalari';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `trendyol_yurtdisi_operasyon`
--

DROP TABLE IF EXISTS `trendyol_yurtdisi_operasyon`;
CREATE TABLE IF NOT EXISTS `trendyol_yurtdisi_operasyon` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `fatura_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_turu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `fatura_tarihi` date DEFAULT NULL,
  `satici_id` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `ek_ucret` decimal(20,8) DEFAULT NULL,
  `satici_ismi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `gonderi_iade` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `gonderi_iade_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `urun_bedeli` decimal(20,8) DEFAULT NULL,
  `net_satis_tutari` decimal(20,8) DEFAULT NULL,
  `hesaplama_orani` decimal(20,8) DEFAULT NULL,
  `iade_onay_tarihi` datetime DEFAULT NULL,
  `aciklama` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ty_yrt_siparis` (`siparis_no`),
  KEY `idx_ty_yrt_tarih` (`fatura_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Trendyol yurtdisi operasyon bedeli';

--
-- Dökümü yapılmış tablolar için kısıtlamalar
--

--
-- Tablo kısıtlamaları `karlilik_ozeti`
--
ALTER TABLE `karlilik_ozeti`
  ADD CONSTRAINT `fk_ozet_siparis` FOREIGN KEY (`siparis_id`) REFERENCES `siparisler` (`id`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `mutabakat`
--
ALTER TABLE `mutabakat`
  ADD CONSTRAINT `fk_mutabakat_siparis` FOREIGN KEY (`siparis_id`) REFERENCES `siparisler` (`id`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `siparis_kalemleri`
--
ALTER TABLE `siparis_kalemleri`
  ADD CONSTRAINT `fk_kalem_siparis` FOREIGN KEY (`siparis_id`) REFERENCES `siparisler` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
