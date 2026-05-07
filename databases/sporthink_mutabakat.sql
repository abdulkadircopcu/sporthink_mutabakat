-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Anamakine: 127.0.0.1:3306
-- Üretim Zamanı: 07 May 2026, 18:54:51
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Amazon islem listesi';

--
-- Tablo döküm verisi `amazon_islemler`
--

INSERT INTO `amazon_islemler` (`id`, `tarih`, `islem_durumu`, `islem_tipi`, `siparis_no`, `takip_no`, `urun_detaylari`, `toplam_urun_fiyatlari`, `toplam_promosyon_indirimleri`, `amazon_ucretleri`, `diger`, `toplam_try`, `olusturma_tarihi`) VALUES
(1, '2026-03-31', 'Oluşturuldu', 'Sipariş Ödemesi', '407-0256391-5303254', NULL, 'xyz Ayakkabı', 1013.95000000, 0.00000000, -223.00000000, 0.00000000, 1236.95000000, '2026-04-24 23:48:35'),
(2, '2026-03-31', 'Oluşturuldu', 'Amazon Kolay Gönderi ücretleri', '326-9783605-7369531', NULL, 'Faturalandırma', 0.00000000, 0.00000000, -75.00000000, 0.00000000, -75.00000000, '2026-04-24 23:48:35'),
(3, '2026-03-31', 'Oluşturuldu', 'Para İadesi', '325-9834561-4538214', NULL, 'xyz ayakkabı ', -202799.00000000, 0.00000000, -236.00000000, 0.00000000, -202563.00000000, '2026-04-24 23:48:35'),
(4, '2026-03-31', 'Oluşturuldu', 'Diğer', '---', NULL, 'xyz düzeltmesi', 0.00000000, 0.00000000, 0.00000000, 60.00000000, 60.00000000, '2026-04-24 23:48:35'),
(5, '2026-03-02', 'Oluşturuldu', 'Hizmet Ücretleri', '---', NULL, 'Reklam Bedelleri', 0.00000000, 0.00000000, -300.00000000, 0.00000000, -300.00000000, '2026-04-24 23:48:35');

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Flo fatura detay';

--
-- Tablo döküm verisi `flo_fatura_detay`
--

INSERT INTO `flo_fatura_detay` (`id`, `fatura_id`, `fatura_no`, `fatura_tarihi`, `siparis_no`, `takip_no`, `islem`, `islem_tipi`, `islem_zamani`, `miktar`, `olusturma_tarihi`) VALUES
(5, '33567.0', 'F012025000262232', '2025-12-17', '2421395933.0', NULL, 'penalty', 'Ceza', '2025-12-12 15:33:20', 70.00000000, '2026-04-24 23:44:43');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Flo kargo desi fiyatlari';

--
-- Tablo döküm verisi `flo_kargo_desi_fiyatlari`
--

INSERT INTO `flo_kargo_desi_fiyatlari` (`id`, `desi`, `hepsijet`, `aras`, `gecerlilik_tarihi`, `olusturma_tarihi`) VALUES
(1, 1.00000000, 52.36000000, 55.63000000, '2026-04-24', '2026-04-24 23:50:28');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Hepsiburada hakedis listesi';

--
-- Tablo döküm verisi `hepsiburada_hakedis`
--

INSERT INTO `hepsiburada_hakedis` (`id`, `hakedis_donemi`, `ongorulen_odeme_tarihi`, `durum`, `odeme_tarihi`, `vade_tarihi`, `kayit_tarihi`, `kayit_no`, `kayit_tipi`, `ceza_tipi`, `kayit_turu`, `kayit_sinifi`, `siparis_no`, `po_no`, `siparis_tarihi`, `urun_no`, `urun_adi`, `urun_adedi`, `birim_tutar`, `liste_fiyati`, `tutar`, `para_birimi`, `vade_suresi`, `paket_no`, `olusturma_tarihi`) VALUES
(1, '2024-12-18 - 2024-12-24', '2024-12-24', 'Ödendi', '2024-12-24', '2024-12-19', '2024-12-01', '5321478963', 'Sipariş tutarı', NULL, 'Gelir', 'Sipariş bazlı', '4569874123', NULL, '2024-11-26 00:00:00', 'HBV00004563256', 'Puma Rs-X Efekt Expeditions.02', 1, 0.00000000, 1326.36000000, 1002.25000000, 'TL', 14, '5321478963', '2026-04-25 00:03:38');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Hepsiburada kargo desi fiyatlari';

--
-- Tablo döküm verisi `hepsiburada_kargo_desi_fiyatlari`
--

INSERT INTO `hepsiburada_kargo_desi_fiyatlari` (`id`, `desi`, `hepsijet`, `aras_kargo`, `mng_kargo`, `yurtici_kargo`, `surat_kargo`, `sendeo`, `ptt_kargo`, `hepsijet_xl`, `horoz_lojistik`, `ceva_lojistik`, `borusan_lojistik`, `gecerlilik_tarihi`, `olusturma_tarihi`) VALUES
(1, 0.00000000, 45.36000000, 48.99000000, 53.99000000, 67.69000000, 48.26000000, 49.80000000, 54.54000000, 289.90000000, 263.45000000, 423.12000000, 335.21000000, '2026-04-24', '2026-04-24 23:54:31');

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
-- Tablo için tablo yapısı `kategori_desi_listesi`
--

DROP TABLE IF EXISTS `kategori_desi_listesi`;
CREATE TABLE IF NOT EXISTS `kategori_desi_listesi` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `ana_kategori` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `alt_kategori` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `cinsiyet` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `tahmini_desi` int NOT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tek_kategori` (`ana_kategori`,`alt_kategori`,`cinsiyet`),
  KEY `idx_ana_kategori` (`ana_kategori`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Kategori bazli tahmini desi listesi';

--
-- Tablo döküm verisi `kategori_desi_listesi`
--

INSERT INTO `kategori_desi_listesi` (`id`, `ana_kategori`, `alt_kategori`, `cinsiyet`, `tahmini_desi`, `olusturma_tarihi`) VALUES
(1, 'Giyim', 'Mont', 'Kadin', 1, '2026-05-07 21:41:57');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='LCW kargo desi fiyatlari';

--
-- Tablo döküm verisi `lcw_kargo_desi_fiyatlari`
--

INSERT INTO `lcw_kargo_desi_fiyatlari` (`id`, `desi`, `aras_kargo`, `hepsijet`, `kargoist`, `surat_kargo`, `yurtici_kargo`, `gecerlilik_tarihi`, `olusturma_tarihi`) VALUES
(1, 0.00000000, 52.29830000, 46.36500000, 34.26980000, 52.36540000, 65.32480000, '2026-04-24', '2026-04-24 23:57:32');

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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='LCW kargo faturalari';

--
-- Tablo döküm verisi `lcw_kargo_faturalari`
--

INSERT INTO `lcw_kargo_faturalari` (`id`, `islem_kayit_no`, `satici`, `cari_kod`, `siparis_no`, `takip_no`, `paket_no`, `kargo_firmasi`, `desi`, `islem_tipi`, `siparis_tarihi`, `sevk_tarihi`, `teslim_tarihi`, `vade_gunu`, `vade_tarihi`, `lcw_kargo_hakedis`, `fatura_no`, `fatura_tarihi`, `olusturma_tarihi`) VALUES
(1, '4768136', 'xyz şirketi', 'TRKAM-00057741', '2412782401419', NULL, '5412222301321', 'abc kargo', 2.00000000, 'x maliyeti', '2024-12-22 23:17:11', '2024-12-23 19:11:58', '2024-12-30 11:33:07', 7, '2025-01-22 12:55:20', 56.27600000, 'AOM2024007965024', '2024-12-31', '2026-04-25 00:06:15'),
(2, '4729963', 'xyz şirketi', 'TRKAM-0005987', '2419231926332', NULL, '5419231992133', 'abc kargo', 1.00000000, 'x  Maliyeti', '2024-12-23 19:50:49', '2024-12-24 17:52:20', '2024-12-28 12:26:32', 7, '2025-01-15 16:59:21', 65.43600000, 'BLE2024000017625', '2024-12-29', '2026-04-25 00:06:22'),
(3, '4622405', 'xyz Şirketi', 'TRKAM-0005963', '2492122301435', NULL, '5462122091271', 'Aras Kargo', 4.00000000, 'İade Kargo Maliyeti', '2024-12-12 20:27:06', '2024-12-16 09:37:28', '2024-12-19 15:59:54', 7, '2024-12-31 17:29:42', 90.02400000, 'BLE2024000017060', '2024-12-22', '2026-04-25 00:06:26'),
(4, '4935691', 'Xyz Şirketi', 'TRKAM-00059632', '2419341408235', NULL, '541130147896245', 'abc kargo', 2.00000000, 'Kargo Maliyeti', '2024-11-30 14:03:29', '2024-12-03 18:06:21', '2024-12-04 16:02:59', 7, '2024-12-18 16:02:59', 63.27600000, 'BLE2024000016470', '2024-12-08', '2026-04-25 00:06:29'),
(5, '4963254', 'xyz şirketi', 'TRMKA-0005796', '2412622300119', NULL, '5473662371355', 'abc kargo', 2.00000000, 'İade Kargo Maliyeti', '2024-12-22 23:17:11', '2024-12-23 19:11:58', '2024-12-30 11:33:07', 7, '2025-01-22 12:55:20', 63.27600000, 'ALE2024000023024', '2024-12-31', '2026-04-25 00:06:32'),
(6, '4647698', 'xyz şirketi', 'TRKAM-0009778', '2412060003654', NULL, '5412060007436', 'Aras Kargo', 3.00000000, 'X maliyeti', '2024-12-06 00:15:29', '2024-12-07 14:36:15', '2024-12-14 13:57:33', 7, '2025-01-06 12:39:20', 89.02400000, 'ABC2024000016365', '2024-12-15', '2026-04-25 00:06:35');

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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='LCW komisyon faturalari';

--
-- Tablo döküm verisi `lcw_komisyon_faturalari`
--

INSERT INTO `lcw_komisyon_faturalari` (`id`, `islem_kayit_no`, `satici`, `cari_kod`, `siparis_no`, `takip_no`, `paket_no`, `barkod`, `marka`, `urun_kategori`, `urun_adi`, `islem_tipi`, `siparis_tarihi`, `islem_tarihi`, `vade_gunu`, `vade_tarihi`, `hakedis_haftasi`, `not_alani`, `muhasebe_gunluk_no`, `pesin_urun_tutari`, `taksitli_urun_tutari`, `lcw_taksit_farki`, `lcwaikiki_sponsorlugu`, `satici_sponsorlugu`, `toplam_indirim`, `indirim_aciklamasi`, `satis_tutari`, `komisyon_orani`, `lcw_komisyon_hakedis`, `lcw_toplam_hakedis`, `satici_hakedis`, `fatura_no`, `fatura_tarihi`, `yan_not`, `mevzuat_pesin_tutar`, `mevzuat_taksitli_tutar`, `olusturma_tarihi`) VALUES
(1, '7398963', 'xyz Şirketi', 'TRKAM-0006537', '2412111932156', NULL, '5412111796348', '5715317896538', 'a', 'x', 'x', 'x', '2024-12-11 19:36:33', '2024-12-16 15:27:48', 14, '2024-12-30 15:27:48', '30.12.2024-05.01.2025 Haftası Hakediş Ödemesi', NULL, '9123632', 2963.99000000, 2963.99000000, 0.00000000, 120.00000000, 1600.00000000, 1363.99000000, 'abc indirim', 1396.30000000, 0.06000000, 56.09950000, 56.09950000, 1103.89050000, 'ABC2024000016365', '2024-12-22', NULL, NULL, NULL, '2026-04-28 21:02:57'),
(2, '7457856', 'XYZ şirketi', 'TRKAM-0009632', '2412190064528', NULL, '5412190063987', '5712830789651', 'x', 'x', 'x', 'x', '2024-12-19 00:02:35', '2024-12-23 11:56:48', 28, '2025-01-20 11:56:48', '20.01.2025-26.01.2025 Haftası Hakediş Ödemesi', NULL, '926613', 2019.99000000, 2019.99000000, 0.00000000, 0.00000000, 0.00000000, 0.00000000, NULL, 3264.00000000, 0.09000000, 102.00000000, 102.00000000, 1300.00000000, 'ABC6024000017377', '2024-12-29', NULL, NULL, NULL, '2026-04-28 21:03:14'),
(3, '7197654', 'xyz şirketi', 'TRKAM-0006325', '2411261796325', NULL, '5411261763214', '8682902896587', 'x', 'x', 'x', 'x', '2024-11-26 17:32:39', '2024-12-02 13:51:42', 14, '2024-12-16 13:51:42', '16.12.2024-22.12.2024 Haftası Hakediş Ödemesi', NULL, '880654', 1496.95000000, 1496.95000000, 0.00000000, 0.00000000, 0.00000000, 0.00000000, NULL, 1496.95000000, 0.06000000, 222.00000000, 222.00000000, 1272.00000000, 'ABX2024003254211', '2024-12-08', NULL, NULL, NULL, '2026-04-28 21:03:17'),
(4, '7297965', 'XYZ şirketi', 'TRKAM-0005963', '2412060009874', NULL, '5412060965872', '5715504963212', 'x', 'x', 'x', 'x', '2024-12-06 00:15:29', '2024-12-09 12:39:20', 28, '2025-01-06 12:39:20', '06.01.2025-12.01.2025 Haftası Hakediş Ödemesi', NULL, '896325', 2563.00000000, 2563.00000000, 0.00000000, 0.00000000, 0.00000000, 0.00000000, NULL, 2639.00000000, 0.09000000, 263.00000000, 263.00000000, 2363.00000000, 'ABD2027896016598', '2024-12-15', NULL, NULL, NULL, '2026-04-28 21:03:20');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='N11 kargo listesi';

--
-- Tablo döküm verisi `n11_kargo`
--

INSERT INTO `n11_kargo` (`id`, `siparis_kodu`, `takip_no`, `kampanya_numarasi`, `musteri`, `islem_tarihi`, `islem_turu`, `kargo_sirketi`, `tl_desi_kg`, `olusturma_tarihi`) VALUES
(1, '206632578963', NULL, '116325193165478', 'x', '2024-12-30 10:06:00', 'abc', 'abc kargo', '50 TL / 5 Desi veya kg', '2026-04-28 21:09:14');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='N11 kargo desi fiyatlari';

--
-- Tablo döküm verisi `n11_kargo_desi_fiyatlari`
--

INSERT INTO `n11_kargo_desi_fiyatlari` (`id`, `desi`, `aras_kargo`, `ptt_kargo`, `yurtici_kargo`, `surat_kargo`, `sendeo_kargo`, `gecerlilik_tarihi`, `olusturma_tarihi`) VALUES
(1, 1.00000000, 47.36000000, 15.30000000, 66.36000000, 48.50000000, 48.60000000, '2026-04-24', '2026-04-24 23:58:56');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='N11 komisyon faturalari';

--
-- Tablo döküm verisi `n11_komisyon_faturalari`
--

INSERT INTO `n11_komisyon_faturalari` (`id`, `fatura_turu`, `fatura_tarihi`, `satici_id`, `magaza_adi`, `siparis_no`, `takip_no`, `siparis_kalem_id`, `islem_tipi_tanimi`, `siparis_tamamlanma_tarihi`, `siparis_tutari`, `komisyon_orani`, `komisyon_bedeli`, `pazarlama_hizmet_bedeli`, `pazaryeri_hizmet_bedeli`, `vade_farki_yansitmasi`, `sozlesme_ceza_bedeli`, `reklam_bedeli`, `k_fatura_numarasi`, `satici_hakedis_tutari`, `hakedis_transfer_tarihi`, `olusturma_tarihi`) VALUES
(1, 'axyz', '2024-12-31', NULL, 'a', '296194546325', NULL, '399196325', 'abc', '0000-00-00', 0.00000000, 0.00000000, 62.89000000, 0.00000000, 0.00000000, 0.00000000, NULL, 0.00000000, 'ABC202400034563', 0.00000000, '0000-00-00', '2026-04-28 21:11:09');

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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Pazarama fatura ozeti';

--
-- Tablo döküm verisi `pazarama_fatura_ozet`
--

INSERT INTO `pazarama_fatura_ozet` (`id`, `bayi_kodu`, `firma_adi`, `fatura_no`, `fatura_tarihi`, `donem`, `vkn`, `komisyon_tutar`, `kargo_tutari`, `entegrasyon_bedeli`, `olusturma_tarihi`) VALUES
(1, '21967 - 25297', 'Sporthink', 'TDK2024000107244', '0000-00-00', '202412', '3090342602', 11694.40000000, 1361.62000000, 669.50000000, '2026-05-07 21:27:54'),
(2, '21967 - 25297', 'Sporthink', 'TDK2024000107244', '0000-00-00', '202412', '3090342602', 11694.40000000, 1361.62000000, 669.50000000, '2026-05-07 21:29:14'),
(3, '21967 - 25297', 'Sporthink', 'TDK2024000107244', '0000-00-00', '202412', '3090342602', 11694.40000000, 1361.62000000, 669.50000000, '2026-05-07 21:34:14');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Pazarama kargo desi fiyatlari';

--
-- Tablo döküm verisi `pazarama_kargo_desi_fiyatlari`
--

INSERT INTO `pazarama_kargo_desi_fiyatlari` (`id`, `desi`, `tutar_kdvsiz`, `gecerlilik_tarihi`, `olusturma_tarihi`) VALUES
(1, 2.00000000, 59.32000000, '2026-04-25', '2026-04-25 00:00:07');

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
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Pazarama kargo detay';

--
-- Tablo döküm verisi `pazarama_kargo_detay`
--

INSERT INTO `pazarama_kargo_detay` (`id`, `fatura_no`, `fatura_tarihi`, `fatura_turu`, `kargo_firmasi`, `bayi_kodu`, `siparis_durumu`, `donem`, `siparis_no`, `takip_no`, `desi`, `satici_borcu`, `gonderi_numarasi`, `olusturma_tarihi`) VALUES
(1, 'TDK2024000107244', '0000-00-00', NULL, NULL, '21967 - 25297', NULL, '202412', NULL, NULL, NULL, NULL, NULL, '2026-04-28 21:19:49'),
(2, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 3.00000000, 77.03000000, 'PZ13263591472', '2026-05-07 21:34:14'),
(3, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 3.00000000, 77.03000000, 'PZ13658670967', '2026-05-07 21:34:14'),
(4, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 3.00000000, 77.03000000, 'PZ11992135801', '2026-05-07 21:34:14'),
(5, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 7.00000000, 102.52000000, 'PZ19187414759', '2026-05-07 21:34:14'),
(6, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 2.50000000, 77.03000000, 'PZ12601437423', '2026-05-07 21:34:14'),
(7, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'Satış', '202412', NULL, NULL, 1.00000000, 71.53000000, 'PZ15394959288', '2026-05-07 21:34:14'),
(8, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 3.00000000, 77.03000000, 'PZ10393292156', '2026-05-07 21:34:14'),
(9, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 3.00000000, 77.03000000, 'PZ15730913845', '2026-05-07 21:34:14'),
(10, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 5.00000000, 87.72000000, 'PZ15702204385', '2026-05-07 21:34:14'),
(11, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 3.00000000, 77.03000000, 'PZ17990717222', '2026-05-07 21:34:14'),
(12, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 4.00000000, 78.53000000, 'PZ19366611427', '2026-05-07 21:34:14'),
(13, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 2.00000000, 72.43000000, 'PZ17487155263', '2026-05-07 21:34:14'),
(14, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 3.00000000, 77.03000000, 'PZ16792708626', '2026-05-07 21:34:14'),
(15, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 1.00000000, 70.65000000, 'PZ17469494747', '2026-05-07 21:34:14'),
(16, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 2.00000000, 72.43000000, 'PZ17027675051', '2026-05-07 21:34:14'),
(17, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 3.00000000, 77.03000000, 'PZ17192068956', '2026-05-07 21:34:14'),
(18, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 1.00000000, 70.65000000, 'PZ15483771001', '2026-05-07 21:34:14'),
(19, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 3.00000000, 77.03000000, 'PZ17312120750', '2026-05-07 21:34:14'),
(20, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 5.00000000, 87.72000000, 'PZ17004480329', '2026-05-07 21:34:14'),
(21, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 3.00000000, 77.03000000, 'PZ16195185966', '2026-05-07 21:34:14'),
(22, 'TDK2024000107244', '0000-00-00', 'Kargo', 'Yurtici', '25297', 'İade', '202412', NULL, NULL, 2.30000000, 72.43000000, 'PZ17993919545', '2026-05-07 21:34:14');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Pazarama komisyon detay';

--
-- Tablo döküm verisi `pazarama_komisyon_detay`
--

INSERT INTO `pazarama_komisyon_detay` (`id`, `fatura_no`, `fatura_tarihi`, `fatura_turu`, `bayi_kodu`, `satici_adi`, `siparis_no`, `takip_no`, `siparis_durumu`, `siparis_tarihi`, `karsi_islem_id`, `siparis_tutari`, `satici_komisyon_tutari`, `entegrasyon_bedeli`, `etm_tutari`, `etm_komisyonu`, `olusturma_tarihi`) VALUES
(1, 'XYZ2024003216654', '0000-00-00', 'x', '26547 - 24523', 'x', '472112365', NULL, 'x', '0000-00-00', 'klm91e22-d43a-4abc-8ece-63dd1b74b75e', 1763.99000000, -88.40000000, -4.50000000, 325.00000000, -27.13000000, '2026-05-07 21:34:14');

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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Trendyol ceza faturalari (kusurlu, yanlis urun, termin gecikme)';

--
-- Tablo döküm verisi `trendyol_ceza_faturalari`
--

INSERT INTO `trendyol_ceza_faturalari` (`id`, `fatura_no`, `fatura_turu`, `fatura_tarihi`, `satici_id`, `satici_ismi`, `siparis_no`, `takip_no`, `iade_kodu`, `fatura_tipi`, `urun_adedi`, `urun_tutari`, `kesilen_bedel`, `gonderi_kodu`, `siparis_tarihi`, `kargo_cikis_tarihi`, `termin`, `geciken_urun_adedi`, `geciken_urun_tutari`, `not_alani`, `olusturma_tarihi`) VALUES
(1, 'ABC2024021257450', 'X', '2024-12-04', '106932', 'X', '9624736987', NULL, '7340019017332650', NULL, 1, 3265.67000000, 210.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-28 21:50:33'),
(2, 'ABC2024045698996', 'x', '2024-12-11', '205694', 'x', '9635101236', NULL, '7630789105965090', NULL, 1, 1547.96000000, 130.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-28 21:50:41'),
(3, 'ABC2024021842365', 'X', '2024-12-11', '745632', 'x', '7454665934', NULL, '8632519250888990', NULL, 2, 463.94000000, 63.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-28 21:50:52'),
(4, 'ABC2024021215963', 'x', '2024-12-04', '635494', 'x', '9623736985', NULL, NULL, NULL, NULL, NULL, 85.00000000, '6325418851346630', '0000-00-00 00:00:00', NULL, NULL, NULL, 2964.56000000, NULL, '2026-04-28 21:51:43'),
(5, 'ABC2024021939654', 'x', '2024-12-11', '632544', 'x', '4635604421', NULL, NULL, NULL, NULL, NULL, 63.00000000, '8563219042593260', '0000-00-00 00:00:00', NULL, NULL, NULL, 2985.47000000, NULL, '2026-04-28 21:51:47'),
(6, 'ABC2024021257450', 'X', '2024-12-04', '106932', 'X', '9624736987', NULL, '7340019017332650', NULL, 1, 3265.67000000, 210.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-28 21:56:21');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Trendyol iptal listesi';

--
-- Tablo döküm verisi `trendyol_iptal_listesi`
--

INSERT INTO `trendyol_iptal_listesi` (`id`, `barkod`, `paket_no`, `siparis_tarihi`, `iptal_tarihi`, `kargo_kodu`, `siparis_no`, `takip_no`, `alici`, `urun_adi`, `marka`, `stok_kodu`, `adet`, `birim_fiyati`, `iptal_tipi`, `iptal_nedeni`, `olusturma_tarihi`) VALUES
(1, '134375744569', '2689463457', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '6330019138965410', '8933943516', NULL, ' x ', 'x', 'x', '186375765649', 1, 3634.25000000, 'x', 'x', '2026-04-28 21:29:07');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Trendyol kargo desi fiyatlari';

--
-- Tablo döküm verisi `trendyol_kargo_desi_fiyatlari`
--

INSERT INTO `trendyol_kargo_desi_fiyatlari` (`id`, `desi`, `aras`, `mng`, `ptt`, `sendeo`, `surat`, `tex`, `yurtici`, `borusan`, `ceva`, `horoz`, `gecerlilik_tarihi`, `olusturma_tarihi`) VALUES
(1, 0.00000000, 53.60000000, 63.54200000, 57.32100000, 56.36000000, 58.65400000, 53.41000000, 79.36500000, 410.36000000, 423.65000000, 462.74600000, '2026-04-25', '2026-04-25 00:00:33');

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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Trendyol kargo faturalari';

--
-- Tablo döküm verisi `trendyol_kargo_faturalari`
--

INSERT INTO `trendyol_kargo_faturalari` (`id`, `fatura_no`, `fatura_turu`, `fatura_tarihi`, `satici_id`, `gonderi_ucreti`, `desi`, `satici_ismi`, `siparis_no`, `takip_no`, `gonderi_iade`, `gonderi_iade_kodu`, `kargo_firmasi`, `siparis_tarihi`, `sevk_tarihi`, `siparis_tutari`, `min_kampanya_baremi`, `urun_adedi`, `butik_id`, `aciklama`, `olusturma_tarihi`) VALUES
(1, 'ABC2024021096547', 'X', '2024-12-02', '708324', 97.13000000, 3.00000000, 'x', '9593945621', NULL, 'x', '7330018429685210', 'x', '2024-11-06 16:56:49', '2024-11-07 17:05:00', 1365.35000000, 230.00000000, 1, NULL, NULL, '2026-04-28 21:34:35'),
(2, 'ABC2024021432015', 'X', '2024-12-05', '106325', 52.13000000, 3.00000000, 'x', '960765412', NULL, 'x', '7330018623074120', 'x', '2024-11-11 21:10:43', '2024-11-14 15:36:00', 1361.41000000, 220.00000000, 1, NULL, NULL, '2026-04-28 21:34:39'),
(3, 'ABX2024021426321', 'x', '2024-12-05', '108423', 56.13000000, 5.00000000, 'x', '6518457777', NULL, 'x', '7330018776463250', 'x', '2024-11-17 21:19:10', '2024-11-18 16:37:00', 1423.91000000, 220.00000000, 1, NULL, NULL, '2026-04-28 21:34:42');

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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Trendyol komisyon faturalari';

--
-- Tablo döküm verisi `trendyol_komisyon_faturalari`
--

INSERT INTO `trendyol_komisyon_faturalari` (`id`, `fatura_no`, `fatura_turu`, `fatura_tarihi`, `satici_id`, `kayit_no`, `islem_tipi`, `siparis_no`, `takip_no`, `siparis_tarihi`, `ulke`, `islem_tarihi`, `satici`, `satici_cari_adi`, `urun_adi`, `barkod`, `komisyon_orani`, `trendyol_hakedis`, `satici_hakedis`, `vade_suresi`, `teslim_tarihi`, `vade_tarihi`, `toplam_tutar`, `musteri_ad`, `musteri_soyad`, `magaza_no`, `magaza_adi`, `magaza_adresi`, `olusturma_tarihi`) VALUES
(1, 'ABC2024005459863', 'x', '2024-12-07', NULL, '6969106532', 'c', '9640323216', NULL, '0000-00-00 00:00:00', 'c', '0000-00-00 00:00:00', 'yfyug', 'vjg', 'jvj', '1200633281263', 2.60000000, 13.09000000, 496.97000000, 11, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 532.06000000, 'El****', 'Sa****', NULL, NULL, NULL, '2026-04-28 21:36:06'),
(2, 'XYZ2024005064563', 'X', '2024-12-07', NULL, '4563233215', 'X', '7838236654', NULL, '0000-00-00 00:00:00', 'X', '0000-00-00 00:00:00', 'X', 'X', 'X', '456502304215', 2.50000000, 12.34000000, 963.57000000, 12, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 456.94000000, 'De****', 'Fe****', NULL, NULL, NULL, '2026-04-28 21:36:10'),
(3, 'XYZ2024005064235', 'x', '2024-12-07', NULL, '6964754563', 'x', '4638777456', NULL, '0000-00-00 00:00:00', 'x', '0000-00-00 00:00:00', 'x', 'x', 'x', '6358686662141', 9.24000000, 135.51000000, 1453.49000000, 11, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1263.00000000, 'fa****', 'ha****', NULL, NULL, NULL, '2026-04-28 21:36:14');

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
