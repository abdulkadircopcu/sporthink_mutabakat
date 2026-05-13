-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Anamakine: 127.0.0.1:3306
-- Üretim Zamanı: 12 May 2026, 18:13:50
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Amazon islem listesi';

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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Flo fatura detay';

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Flo kargo desi fiyatlari';

--
-- Tablo döküm verisi `flo_kargo_desi_fiyatlari`
--

INSERT INTO `flo_kargo_desi_fiyatlari` (`id`, `desi`, `hepsijet`, `aras`, `gecerlilik_tarihi`, `olusturma_tarihi`) VALUES
(1, 1.00000000, 52.36000000, 55.63000000, '2026-05-12', '2026-05-12 21:05:39'),
(2, 2.00000000, 59.16680000, 62.86190000, '2026-05-12', '2026-05-12 21:05:39'),
(3, 3.00000000, 66.85850000, 71.03390000, '2026-05-12', '2026-05-12 21:05:39'),
(4, 4.00000000, 75.55010000, 80.26840000, '2026-05-12', '2026-05-12 21:05:39'),
(5, 5.00000000, 85.37160000, 90.70320000, '2026-05-12', '2026-05-12 21:05:39');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `hamurlab_iptal_iade`
--

DROP TABLE IF EXISTS `hamurlab_iptal_iade`;
CREATE TABLE IF NOT EXISTS `hamurlab_iptal_iade` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `siparis_tarihi` datetime DEFAULT NULL,
  `siparis_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kaynak` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `magaza` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `takip_numarasi` varchar(200) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Ham — birlesik gelebilir',
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Ayristirilan takip no',
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Ayristirilan siparis no',
  `siparis_durumu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `urun_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `urun_adi` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `barkod` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Eslesme anahtari',
  `sku` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `iade_iptal_adedi` smallint DEFAULT NULL,
  `satis_fiyati` decimal(20,8) DEFAULT NULL,
  `kaynak_depo` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `tam_parcali` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Full / Parcali',
  `iade_iptal_turu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Iade mi iptal mi',
  `iade_iptal_tarihi` datetime DEFAULT NULL,
  `neden` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kargo_kampanya_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `iade_iptal_orani` decimal(20,8) DEFAULT NULL,
  `odeme_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `iade_iptal_satis_fiyati` decimal(20,8) DEFAULT NULL,
  `iade_edilecek_toplam_tutar` decimal(20,8) DEFAULT NULL,
  `ret_nedeni` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `ret_aciklamasi` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `durum` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kargo_kabul_tarihi` datetime DEFAULT NULL,
  `teslim_tarihi` datetime DEFAULT NULL,
  `musteri` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `iade_kargo_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `tasiyici` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kategori_grubu` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `marka` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `tedarikci_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `eticaret_ana_grup` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_hl_i_takip` (`takip_no`),
  KEY `idx_hl_i_siparis` (`siparis_no`),
  KEY `idx_hl_i_barkod` (`barkod`),
  KEY `idx_hl_i_tur` (`iade_iptal_turu`),
  KEY `idx_hl_i_tarih` (`iade_iptal_tarihi`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Hamurlab iptal ve iade listesi';

--
-- Tablo döküm verisi `hamurlab_iptal_iade`
--

INSERT INTO `hamurlab_iptal_iade` (`id`, `siparis_tarihi`, `siparis_tipi`, `kaynak`, `magaza`, `takip_numarasi`, `takip_no`, `siparis_no`, `siparis_durumu`, `urun_kodu`, `urun_adi`, `barkod`, `sku`, `iade_iptal_adedi`, `satis_fiyati`, `kaynak_depo`, `tam_parcali`, `iade_iptal_turu`, `iade_iptal_tarihi`, `neden`, `kargo_kampanya_kodu`, `iade_iptal_orani`, `odeme_tipi`, `iade_iptal_satis_fiyati`, `iade_edilecek_toplam_tutar`, `ret_nedeni`, `ret_aciklamasi`, `durum`, `kargo_kabul_tarihi`, `teslim_tarihi`, `musteri`, `iade_kargo_kodu`, `tasiyici`, `kategori_grubu`, `marka`, `tedarikci_kodu`, `eticaret_ana_grup`, `olusturma_tarihi`) VALUES
(1, '0000-00-00 00:00:00', 'x', 'x', 'x', '32153296257-1', '32153296257', '1', 'x', '154-AB6754-2', 'X', NULL, '163279728789', 1, 12239.90000000, 'x', 'x', 'x', '0000-00-00 00:00:00', 'x', '5412196257-1', 0.00000000, NULL, 16499.90000000, 15799.90000000, NULL, NULL, 'x', NULL, NULL, 'x', NULL, 'x', NULL, 'x', 'AB6236-010', 'x', '2026-05-10 22:10:25');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `hamurlab_siparisler`
--

DROP TABLE IF EXISTS `hamurlab_siparisler`;
CREATE TABLE IF NOT EXISTS `hamurlab_siparisler` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `takip_numarasi` varchar(200) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Ham — takip_no_siparis_no birlesik',
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Ayristirilan takip no',
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Ayristirilan siparis no',
  `siparis_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `magaza` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Pazaryeri',
  `urun_adi` varchar(500) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `urun_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `barkod` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Eslesme anahtari',
  `marka` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `varyant` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `adet` smallint DEFAULT NULL,
  `fiyat` decimal(20,8) DEFAULT NULL,
  `kdv_orani` decimal(20,8) DEFAULT NULL,
  `kdvsiz_satis_fiyati` decimal(20,8) DEFAULT NULL,
  `musteri` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `olusma_zamani` datetime DEFAULT NULL,
  `toplama_kapanis_zamani` datetime DEFAULT NULL,
  `paketleme_tarihi` datetime DEFAULT NULL,
  `kargo_gonderim_tarihi` datetime DEFAULT NULL,
  `durum` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kargo_kampanya_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `erp_olusma_zamani` datetime DEFAULT NULL,
  `urun_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `renk` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `po` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Siparis no',
  `kategori_grubu` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Desi hesabi icin',
  `sku` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `ean` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `kaynak` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `odeme_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `set_barkodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `teslim_tarihi` datetime DEFAULT NULL,
  `desi` decimal(20,8) DEFAULT NULL COMMENT 'Hamurlab desi degeri',
  `siparis_desisi` decimal(20,8) DEFAULT NULL,
  `ilk_urun_adedi` smallint DEFAULT NULL,
  `iptal_urun_adedi` smallint DEFAULT NULL,
  `iade_urun_adedi` smallint DEFAULT NULL,
  `komisyon` decimal(20,8) DEFAULT NULL,
  `toplanan_adet` smallint DEFAULT NULL,
  `paketlenmemis_adet` smallint DEFAULT NULL,
  `gonderim_tipi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `satis_anindaki_fiyat` decimal(20,8) DEFAULT NULL,
  `toplam_fiyat` decimal(20,8) DEFAULT NULL,
  `pazar_yeri_fiyati` decimal(20,8) DEFAULT NULL,
  `entegrasyon_indirim_orani` decimal(20,8) DEFAULT NULL,
  `indirim_tutari` decimal(20,8) DEFAULT NULL,
  `kdvsiz_toplam_fiyat` decimal(20,8) DEFAULT NULL,
  `magaza_indirim_tutari` decimal(20,8) DEFAULT NULL,
  `external_id` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_hl_s_takip` (`takip_no`),
  KEY `idx_hl_s_siparis` (`siparis_no`),
  KEY `idx_hl_s_barkod` (`barkod`),
  KEY `idx_hl_s_magaza` (`magaza`),
  KEY `idx_hl_s_tarih` (`olusma_zamani`)
) ENGINE=InnoDB AUTO_INCREMENT=152 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Hamurlab siparis listesi';

--
-- Tablo döküm verisi `hamurlab_siparisler`
--

INSERT INTO `hamurlab_siparisler` (`id`, `takip_numarasi`, `takip_no`, `siparis_no`, `siparis_tipi`, `magaza`, `urun_adi`, `urun_kodu`, `barkod`, `marka`, `varyant`, `adet`, `fiyat`, `kdv_orani`, `kdvsiz_satis_fiyati`, `musteri`, `olusma_zamani`, `toplama_kapanis_zamani`, `paketleme_tarihi`, `kargo_gonderim_tarihi`, `durum`, `kargo_kampanya_kodu`, `erp_olusma_zamani`, `urun_tipi`, `renk`, `po`, `kategori_grubu`, `sku`, `ean`, `kaynak`, `odeme_tipi`, `set_barkodu`, `teslim_tarihi`, `desi`, `siparis_desisi`, `ilk_urun_adedi`, `iptal_urun_adedi`, `iade_urun_adedi`, `komisyon`, `toplanan_adet`, `paketlenmemis_adet`, `gonderim_tipi`, `satis_anindaki_fiyat`, `toplam_fiyat`, `pazar_yeri_fiyati`, `entegrasyon_indirim_orani`, `indirim_tutari`, `kdvsiz_toplam_fiyat`, `magaza_indirim_tutari`, `external_id`, `olusturma_tarihi`) VALUES
(102, '4264675742_7723457100', '4264675742', '7723457100', 'Standart', 'Hepsiburada', 'Canta', '01-AB6697-1', '1010101010101', 'Nike', 'S', 1, 536.09000000, 10.00000000, 487.35000000, 'Fatma Celik', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '6484957545105959', '2024-12-24 03:00:00', 'Fiziksel', 'Gri', '7723457100', 'Aksesuar -> Canta', '5497264070986', '1010101010101', 'Hepsiburada', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 51.13000000, 1, 0, 'Kargo', 536.09000000, 536.09000000, 589.70000000, 10.00000000, 32.86000000, 487.35000000, 0.00000000, '9727394164', '2026-05-11 22:30:04'),
(103, '1849684983_6651704635', '1849684983', '6651704635', 'Standart', 'Amazon', 'Erkek Tisort', '01-AB1744-1', '2222222222222', 'Hummel', 'XL', 1, 205.68000000, 10.00000000, 186.98000000, 'Ali Oz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '2248927873283345', '2025-01-10 20:00:00', 'Fiziksel', 'Gri', '6651704635', 'Giyim -> Tisort -> Erkek', '3464390980843', '2222222222222', 'Amazon', 'Havale', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 19.74000000, 1, 0, 'Kargo', 205.68000000, 205.68000000, 226.25000000, 5.00000000, 5.43000000, 186.98000000, 0.00000000, '3327274462', '2026-05-11 22:30:04'),
(104, '6732988898_5924867347', '6732988898', '5924867347', 'Standart', 'Hepsiburada', 'Unisex Ceket', '01-AB6629-1', '8888888888888', 'Nike', '42', 1, 1369.27000000, 10.00000000, 1244.79000000, 'Ali Oz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '8861517132194836', '2025-01-05 17:00:00', 'Fiziksel', 'Kirmizi', '5924867347', 'Giyim -> Ceket -> Unisex', '2870429760966', '8888888888888', 'Hepsiburada', 'Havale', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 173.42000000, 1, 0, 'Kargo', 1369.27000000, 1369.27000000, 1506.20000000, 5.00000000, 57.29000000, 1244.79000000, 0.00000000, '5744643861', '2026-05-11 22:30:04'),
(105, '6728200490_6702496208', '6728200490', '6702496208', 'Standart', 'Hepsiburada', 'Kadin Sweatshirt', '01-AB6101-1', '9999999999999', 'Columbia', 'M', 1, 566.60000000, 10.00000000, 515.09000000, 'Mehmet Demir', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Hazirlaniyor', '4424271295529801', '2025-01-29 16:00:00', 'Fiziksel', 'Beyaz', '6702496208', 'Giyim -> Sweatshirt -> Kadin', '5024407730972', '9999999999999', 'Hepsiburada', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 74.38000000, 1, 0, 'Kargo', 566.60000000, 566.60000000, 623.26000000, 15.00000000, 29.21000000, 515.09000000, 0.00000000, '8172041721', '2026-05-11 22:30:04'),
(106, '9530351872_8386238333', '9530351872', '8386238333', 'Standart', 'Flo', 'Erkek Bot', '01-AB9094-1', '7777777777777', 'Hummel', 'L', 1, 2384.62000000, 10.00000000, 2167.84000000, 'Ahmet Yilmaz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '4820656214082473', '2024-12-28 06:00:00', 'Fiziksel', 'Gri', '8386238333', 'Ayakkabi -> Bot -> Erkek', '3098337938447', '7777777777777', 'Flo', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 3.00000000, 3.00000000, 1, 0, 0, 229.56000000, 1, 0, 'Kargo', 2384.62000000, 2384.62000000, 2623.08000000, 15.00000000, 117.41000000, 2167.84000000, 0.00000000, '9545221779', '2026-05-11 22:30:04'),
(107, '8956789127_5959846295', '8956789127', '5959846295', 'Standart', 'Hepsiburada', 'Kadin Gunluk Ayakkabi', '01-AB9008-1', '6666666666666', 'Nike', '40', 1, 1242.18000000, 10.00000000, 1129.25000000, 'Ali Oz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Hazirlaniyor', '6096530017620508', '2025-01-12 16:00:00', 'Fiziksel', 'Lacivert', '5959846295', 'Ayakkabi -> Gunluk -> Kadin', '9057480905859', '6666666666666', 'Hepsiburada', 'Havale', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 149.26000000, 1, 0, 'Kargo', 1242.18000000, 1242.18000000, 1366.40000000, 15.00000000, 28.77000000, 1129.25000000, 0.00000000, '6573480664', '2026-05-11 22:30:04'),
(108, '8536201600_7404552443', '8536201600', '7404552443', 'Standart', 'Amazon', 'Unisex Ceket', '01-AB3716-1', '8888888888888', 'Adidas', 'L', 1, 609.46000000, 10.00000000, 554.05000000, 'Ayse Kaya', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '2632975732099386', '2025-01-14 11:00:00', 'Fiziksel', 'Lacivert', '7404552443', 'Giyim -> Ceket -> Unisex', '8451686569476', '8888888888888', 'Amazon', 'Havale', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 79.77000000, 1, 0, 'Kargo', 609.46000000, 609.46000000, 670.41000000, 15.00000000, 11.16000000, 554.05000000, 0.00000000, '5294662524', '2026-05-11 22:30:04'),
(109, '8367905200_2412530567', '8367905200', '2412530567', 'Standart', 'Flo', 'Erkek Esofman', '01-AB8967-1', '4444444444444', 'Columbia', 'XL', 1, 577.62000000, 10.00000000, 525.11000000, 'Ali Oz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Hazirlaniyor', '6218110620531228', '2025-01-01 16:00:00', 'Fiziksel', 'Beyaz', '2412530567', 'Giyim -> Esofman -> Erkek', '1735345419192', '4444444444444', 'Flo', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 86.23000000, 1, 0, 'Kargo', 577.62000000, 577.62000000, 635.38000000, 15.00000000, 10.72000000, 525.11000000, 0.00000000, '1045072034', '2026-05-11 22:30:04'),
(110, '5621714554_2363183019', '5621714554', '2363183019', 'Standart', 'Amazon', 'Canta', '01-AB1004-1', '1010101010101', 'Columbia', '41', 1, 619.44000000, 10.00000000, 563.13000000, 'Ayse Kaya', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Hazirlaniyor', '6440540611676670', '2024-12-30 00:00:00', 'Fiziksel', 'Lacivert', '2363183019', 'Aksesuar -> Canta', '1693516555810', '1010101010101', 'Amazon', 'Havale', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 63.54000000, 1, 0, 'Kargo', 619.44000000, 619.44000000, 681.38000000, 0.00000000, 26.68000000, 563.13000000, 0.00000000, '1890631064', '2026-05-11 22:30:04'),
(111, '2782276805_3433902457', '2782276805', '3433902457', 'Standart', 'Trendyol', 'Kadin Elbise', '01-AB1678-1', '5555555555555', 'Puma', 'L', 1, 360.00000000, 10.00000000, 327.27000000, 'Ahmet Yilmaz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '3775177124642394', '2024-12-08 05:00:00', 'Fiziksel', 'Kirmizi', '3433902457', 'Giyim -> Elbise -> Kadin', '1329027950370', '5555555555555', 'Trendyol', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 36.94000000, 1, 0, 'Kargo', 360.00000000, 360.00000000, 396.00000000, 10.00000000, 7.00000000, 327.27000000, 0.00000000, '9281763183', '2026-05-11 22:30:04'),
(112, '2487054642_7354534701', '2487054642', '7354534701', 'Standart', 'Pazarama', 'Canta', '01-AB3064-1', '1010101010101', 'Puma', '38', 1, 986.87000000, 10.00000000, 897.15000000, 'Mehmet Demir', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '2234953918956914', '2024-12-15 17:00:00', 'Fiziksel', 'Beyaz', '7354534701', 'Aksesuar -> Canta', '1210323825917', '1010101010101', 'Pazarama', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 115.94000000, 1, 0, 'Kargo', 986.87000000, 986.87000000, 1085.56000000, 0.00000000, 40.71000000, 897.15000000, 0.00000000, '8143008909', '2026-05-11 22:30:04'),
(113, '9689932539_8436176325', '9689932539', '8436176325', 'Standart', 'LCW', 'Kadin Gunluk Ayakkabi', '01-AB7512-1', '6666666666666', 'Adidas', 'S', 1, 1419.28000000, 10.00000000, 1290.25000000, 'Zeynep Arslan', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '1875288487942756', '2024-12-22 06:00:00', 'Fiziksel', 'Beyaz', '8436176325', 'Ayakkabi -> Gunluk -> Kadin', '2739902792005', '6666666666666', 'LCW', 'Havale', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 190.27000000, 1, 0, 'Kargo', 1419.28000000, 1419.28000000, 1561.21000000, 0.00000000, 129.77000000, 1290.25000000, 0.00000000, '6319084733', '2026-05-11 22:30:04'),
(114, '4621997119_9933534951', '4621997119', '9933534951', 'Standart', 'Pazarama', 'Kadin Sweatshirt', '01-AB5059-1', '9999999999999', 'Puma', '39', 1, 829.93000000, 10.00000000, 754.48000000, 'Fatma Celik', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '2435852258434512', '2025-01-08 19:00:00', 'Fiziksel', 'Beyaz', '9933534951', 'Giyim -> Sweatshirt -> Kadin', '6122351482673', '9999999999999', 'Pazarama', 'Havale', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 87.64000000, 1, 0, 'Kargo', 829.93000000, 829.93000000, 912.92000000, 15.00000000, 81.66000000, 754.48000000, 0.00000000, '4708008130', '2026-05-11 22:30:04'),
(115, '5130758810_1499895106', '5130758810', '1499895106', 'Standart', 'Trendyol', 'Unisex Ceket', '01-AB8589-1', '8888888888888', 'New Balance', '40', 1, 1528.36000000, 10.00000000, 1389.42000000, 'Ahmet Yilmaz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '4747018880651967', '2025-01-30 09:00:00', 'Fiziksel', 'Siyah', '1499895106', 'Giyim -> Ceket -> Unisex', '8947942093246', '8888888888888', 'Trendyol', 'Havale', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 227.92000000, 1, 0, 'Kargo', 1528.36000000, 1528.36000000, 1681.20000000, 10.00000000, 24.58000000, 1389.42000000, 0.00000000, '9564844579', '2026-05-11 22:30:04'),
(116, '5366495917_9255677709', '5366495917', '9255677709', 'Standart', 'Trendyol', 'Erkek Esofman', '01-AB1257-1', '4444444444444', 'Puma', '40', 1, 401.54000000, 10.00000000, 365.04000000, 'Mehmet Demir', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '6005738016128819', '2024-12-18 17:00:00', 'Fiziksel', 'Siyah', '9255677709', 'Giyim -> Esofman -> Erkek', '6460629535384', '4444444444444', 'Trendyol', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 51.26000000, 1, 0, 'Kargo', 401.54000000, 401.54000000, 441.69000000, 15.00000000, 7.26000000, 365.04000000, 0.00000000, '7756551460', '2026-05-11 22:30:04'),
(117, '9144908062_7456056141', '9144908062', '7456056141', 'Standart', 'N11', 'Canta', '01-AB7419-1', '1010101010101', 'Adidas', '40', 1, 331.56000000, 10.00000000, 301.42000000, 'Ayse Kaya', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Hazirlaniyor', '8154522150058430', '2025-01-17 15:00:00', 'Fiziksel', 'Gri', '7456056141', 'Aksesuar -> Canta', '4698360600135', '1010101010101', 'N11', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 37.41000000, 1, 0, 'Kargo', 331.56000000, 331.56000000, 364.72000000, 10.00000000, 18.37000000, 301.42000000, 0.00000000, '1231878444', '2026-05-11 22:30:04'),
(118, '5754358846_5035679972', '5754358846', '5035679972', 'Standart', 'LCW', 'Erkek Esofman', '01-AB7563-1', '4444444444444', 'Adidas', '39', 1, 762.72000000, 10.00000000, 693.38000000, 'Mehmet Demir', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '4842539706848268', '2025-01-17 20:00:00', 'Fiziksel', 'Siyah', '5035679972', 'Giyim -> Esofman -> Erkek', '2470673864712', '4444444444444', 'LCW', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 68.30000000, 1, 0, 'Kargo', 762.72000000, 762.72000000, 838.99000000, 0.00000000, 61.73000000, 693.38000000, 0.00000000, '6743644497', '2026-05-11 22:30:04'),
(119, '6988511535_8738494786', '6988511535', '8738494786', 'Standart', 'Pazarama', 'Unisex Ceket', '01-AB4301-1', '8888888888888', 'Hummel', 'L', 1, 629.71000000, 10.00000000, 572.46000000, 'Mehmet Demir', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Hazirlaniyor', '8052977325891194', '2024-12-31 06:00:00', 'Fiziksel', 'Beyaz', '8738494786', 'Giyim -> Ceket -> Unisex', '1821077568840', '8888888888888', 'Pazarama', 'Havale', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 90.08000000, 1, 0, 'Kargo', 629.71000000, 629.71000000, 692.68000000, 10.00000000, 36.73000000, 572.46000000, 0.00000000, '9802511018', '2026-05-11 22:30:04'),
(120, '3804090187_2204481679', '3804090187', '2204481679', 'Standart', 'Flo', 'Kadin Gunluk Ayakkabi', '01-AB8168-1', '6666666666666', 'Adidas', 'L', 1, 904.14000000, 10.00000000, 821.95000000, 'Ali Oz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '2234115062088974', '2024-12-13 07:00:00', 'Fiziksel', 'Beyaz', '2204481679', 'Ayakkabi -> Gunluk -> Kadin', '2092602288400', '6666666666666', 'Flo', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 120.16000000, 1, 0, 'Kargo', 904.14000000, 904.14000000, 994.55000000, 5.00000000, 36.55000000, 821.95000000, 0.00000000, '6025652116', '2026-05-11 22:30:04'),
(121, '4104423785_3838220535', '4104423785', '3838220535', 'Standart', 'LCW', 'Erkek Bot', '01-AB7271-1', '7777777777777', 'Nike', '41', 1, 2239.70000000, 10.00000000, 2036.09000000, 'Mehmet Demir', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '2032890113320205', '2024-12-11 17:00:00', 'Fiziksel', 'Siyah', '3838220535', 'Ayakkabi -> Bot -> Erkek', '4531396815094', '7777777777777', 'LCW', 'Havale', NULL, '0000-00-00 00:00:00', 3.00000000, 3.00000000, 1, 0, 0, 277.85000000, 1, 0, 'Kargo', 2239.70000000, 2239.70000000, 2463.67000000, 5.00000000, 45.17000000, 2036.09000000, 0.00000000, '4720302740', '2026-05-11 22:30:04'),
(122, '5146868116_5696995250', '5146868116', '5696995250', 'Standart', 'LCW', 'Unisex Spor Ayakkabi', '01-AB1827-1', '3333333333333', 'Adidas', '41', 1, 737.12000000, 10.00000000, 670.11000000, 'Ali Oz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '6250483575447871', '2025-01-10 05:00:00', 'Fiziksel', 'Kirmizi', '5696995250', 'Ayakkabi -> Spor', '3802123582604', '3333333333333', 'LCW', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 84.47000000, 1, 0, 'Kargo', 737.12000000, 737.12000000, 810.83000000, 15.00000000, 12.39000000, 670.11000000, 0.00000000, '4386858055', '2026-05-11 22:30:04'),
(123, '1919867916_6587697097', '1919867916', '6587697097', 'Standart', 'Amazon', 'Kadin Mont', '01-AB6272-1', '1111111111111', 'New Balance', '39', 1, 2052.86000000, 10.00000000, 1866.24000000, 'Ayse Kaya', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '7268151511565846', '2025-01-23 01:00:00', 'Fiziksel', 'Kirmizi', '6587697097', 'Giyim -> Mont -> Kadin', '6963144862689', '1111111111111', 'Amazon', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 271.62000000, 1, 0, 'Kargo', 2052.86000000, 2052.86000000, 2258.15000000, 0.00000000, 134.95000000, 1866.24000000, 0.00000000, '8753268078', '2026-05-11 22:30:04'),
(124, '1327389376_6757376373', '1327389376', '6757376373', 'Standart', 'Trendyol', 'Kadin Elbise', '01-AB8908-1', '5555555555555', 'Reebok', '41', 1, 852.44000000, 10.00000000, 774.95000000, 'Ahmet Yilmaz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '2006295453283568', '2025-01-02 11:00:00', 'Fiziksel', 'Beyaz', '6757376373', 'Giyim -> Elbise -> Kadin', '7311169712755', '5555555555555', 'Trendyol', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 90.47000000, 1, 0, 'Kargo', 852.44000000, 852.44000000, 937.68000000, 0.00000000, 10.24000000, 774.95000000, 0.00000000, '6568779334', '2026-05-11 22:30:04'),
(125, '2671749205_9123547824', '2671749205', '9123547824', 'Standart', 'Pazarama', 'Unisex Spor Ayakkabi', '01-AB5717-1', '3333333333333', 'Nike', '38', 1, 582.73000000, 10.00000000, 529.75000000, 'Zeynep Arslan', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '8932287426183782', '2024-12-05 03:00:00', 'Fiziksel', 'Siyah', '9123547824', 'Ayakkabi -> Spor', '2573644793125', '3333333333333', 'Pazarama', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 53.57000000, 1, 0, 'Kargo', 582.73000000, 582.73000000, 641.00000000, 15.00000000, 36.38000000, 529.75000000, 0.00000000, '2893661096', '2026-05-11 22:30:04'),
(126, '7974106541_5516173473', '7974106541', '5516173473', 'Standart', 'N11', 'Erkek Bot', '01-AB4024-1', '7777777777777', 'Adidas', '42', 1, 794.26000000, 10.00000000, 722.05000000, 'Ayse Kaya', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Hazirlaniyor', '3554913356254898', '2025-01-06 03:00:00', 'Fiziksel', 'Beyaz', '5516173473', 'Ayakkabi -> Bot -> Erkek', '5554821795955', '7777777777777', 'N11', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 3.00000000, 3.00000000, 1, 0, 0, 97.57000000, 1, 0, 'Kargo', 794.26000000, 794.26000000, 873.69000000, 15.00000000, 45.45000000, 722.05000000, 0.00000000, '6516967565', '2026-05-11 22:30:04'),
(127, '4670271555_1775628967', '4670271555', '1775628967', 'Standart', 'Trendyol', 'Unisex Ceket', '01-AB3497-1', '8888888888888', 'Columbia', 'XL', 1, 1177.94000000, 10.00000000, 1070.85000000, 'Fatma Celik', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '5414762454359783', '2025-01-20 13:00:00', 'Fiziksel', 'Lacivert', '1775628967', 'Giyim -> Ceket -> Unisex', '2084295263603', '8888888888888', 'Trendyol', 'Havale', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 102.79000000, 1, 0, 'Kargo', 1177.94000000, 1177.94000000, 1295.73000000, 15.00000000, 46.57000000, 1070.85000000, 0.00000000, '4340433736', '2026-05-11 22:30:04'),
(128, '9340182226_3462668187', '9340182226', '3462668187', 'Standart', 'LCW', 'Unisex Spor Ayakkabi', '01-AB6501-1', '3333333333333', 'Puma', '38', 1, 1960.24000000, 10.00000000, 1782.04000000, 'Zeynep Arslan', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '1795555841399179', '2024-12-03 11:00:00', 'Fiziksel', 'Beyaz', '3462668187', 'Ayakkabi -> Spor', '5901104597539', '3333333333333', 'LCW', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 220.41000000, 1, 0, 'Kargo', 1960.24000000, 1960.24000000, 2156.26000000, 15.00000000, 47.04000000, 1782.04000000, 0.00000000, '2809697582', '2026-05-11 22:30:04'),
(129, '8902659967_6751878730', '8902659967', '6751878730', 'Standart', 'Amazon', 'Erkek Bot', '01-AB1955-1', '7777777777777', 'Nike', 'S', 1, 1144.01000000, 10.00000000, 1040.01000000, 'Zeynep Arslan', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '6165592047290238', '2025-01-24 08:00:00', 'Fiziksel', 'Gri', '6751878730', 'Ayakkabi -> Bot -> Erkek', '6718605916761', '7777777777777', 'Amazon', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 3.00000000, 3.00000000, 1, 0, 0, 135.31000000, 1, 0, 'Kargo', 1144.01000000, 1144.01000000, 1258.41000000, 10.00000000, 86.93000000, 1040.01000000, 0.00000000, '7504159076', '2026-05-11 22:30:04'),
(130, '3596800447_9735009373', '3596800447', '9735009373', 'Standart', 'N11', 'Kadin Sweatshirt', '01-AB6673-1', '9999999999999', 'Nike', 'M', 1, 575.51000000, 10.00000000, 523.19000000, 'Ahmet Yilmaz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Hazirlaniyor', '8173965760957033', '2024-12-03 18:00:00', 'Fiziksel', 'Beyaz', '9735009373', 'Giyim -> Sweatshirt -> Kadin', '5942975398808', '9999999999999', 'N11', 'Havale', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 75.54000000, 1, 0, 'Kargo', 575.51000000, 575.51000000, 633.06000000, 0.00000000, 37.17000000, 523.19000000, 0.00000000, '4870303671', '2026-05-11 22:30:04'),
(131, '1739120892_9116101879', '1739120892', '9116101879', 'Standart', 'Trendyol', 'Kadin Gunluk Ayakkabi', '01-AB6053-1', '6666666666666', 'Puma', '38', 1, 1701.76000000, 10.00000000, 1547.05000000, 'Fatma Celik', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '8336960081675789', '2025-01-14 09:00:00', 'Fiziksel', 'Siyah', '9116101879', 'Ayakkabi -> Gunluk -> Kadin', '5576808628197', '6666666666666', 'Trendyol', 'Havale', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 219.76000000, 1, 0, 'Kargo', 1701.76000000, 1701.76000000, 1871.94000000, 0.00000000, 13.76000000, 1547.05000000, 0.00000000, '8099301715', '2026-05-11 22:30:04'),
(132, '7961805572_3699356126', '7961805572', '3699356126', 'Standart', 'LCW', 'Canta', '01-AB9830-1', '1010101010101', 'Nike', 'S', 1, 525.60000000, 10.00000000, 477.82000000, 'Fatma Celik', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '2794054467385806', '2024-12-26 09:00:00', 'Fiziksel', 'Lacivert', '3699356126', 'Aksesuar -> Canta', '5134626510490', '1010101010101', 'LCW', 'Havale', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 54.80000000, 1, 0, 'Kargo', 525.60000000, 525.60000000, 578.16000000, 15.00000000, 28.74000000, 477.82000000, 0.00000000, '2722153970', '2026-05-11 22:30:04'),
(133, '2688521890_8541990551', '2688521890', '8541990551', 'Standart', 'Flo', 'Canta', '01-AB3612-1', '1010101010101', 'Nike', 'M', 1, 945.58000000, 10.00000000, 859.62000000, 'Ahmet Yilmaz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Hazirlaniyor', '7892286434553216', '2024-12-30 06:00:00', 'Fiziksel', 'Gri', '8541990551', 'Aksesuar -> Canta', '2952739958311', '1010101010101', 'Flo', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 100.08000000, 1, 0, 'Kargo', 945.58000000, 945.58000000, 1040.14000000, 0.00000000, 78.20000000, 859.62000000, 0.00000000, '7416839951', '2026-05-11 22:30:04'),
(134, '5364362201_5841159565', '5364362201', '5841159565', 'Standart', 'Trendyol', 'Kadin Mont', '01-AB4536-1', '1111111111111', 'Columbia', 'XL', 1, 2762.88000000, 10.00000000, 2511.71000000, 'Mehmet Demir', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Hazirlaniyor', '3031628572365736', '2024-12-07 04:00:00', 'Fiziksel', 'Lacivert', '5841159565', 'Giyim -> Mont -> Kadin', '2813594449951', '1111111111111', 'Trendyol', 'Havale', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 390.61000000, 1, 0, 'Kargo', 2762.88000000, 2762.88000000, 3039.17000000, 15.00000000, 250.10000000, 2511.71000000, 0.00000000, '6679411938', '2026-05-11 22:30:04'),
(135, '2130386388_8370246835', '2130386388', '8370246835', 'Standart', 'LCW', 'Erkek Tisort', '01-AB2204-1', '2222222222222', 'Reebok', '39', 1, 378.31000000, 10.00000000, 343.92000000, 'Fatma Celik', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '2851174521767471', '2025-01-27 03:00:00', 'Fiziksel', 'Siyah', '8370246835', 'Giyim -> Tisort -> Erkek', '9476653965930', '2222222222222', 'LCW', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 54.72000000, 1, 0, 'Kargo', 378.31000000, 378.31000000, 416.14000000, 0.00000000, 28.00000000, 343.92000000, 0.00000000, '8243245322', '2026-05-11 22:30:04'),
(136, '2329460683_5949192636', '2329460683', '5949192636', 'Standart', 'Trendyol', 'Kadin Sweatshirt', '01-AB6261-1', '9999999999999', 'Puma', '40', 1, 610.14000000, 10.00000000, 554.67000000, 'Ayse Kaya', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Hazirlaniyor', '6057301671590341', '2024-12-16 03:00:00', 'Fiziksel', 'Lacivert', '5949192636', 'Giyim -> Sweatshirt -> Kadin', '3296649045548', '9999999999999', 'Trendyol', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 74.41000000, 1, 0, 'Kargo', 610.14000000, 610.14000000, 671.15000000, 5.00000000, 57.53000000, 554.67000000, 0.00000000, '6943588183', '2026-05-11 22:30:04'),
(137, '3723410016_3476439344', '3723410016', '3476439344', 'Standart', 'Pazarama', 'Erkek Esofman', '01-AB3042-1', '4444444444444', 'Hummel', 'M', 1, 1042.49000000, 10.00000000, 947.72000000, 'Mehmet Demir', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '6215313980607615', '2024-12-11 00:00:00', 'Fiziksel', 'Kirmizi', '3476439344', 'Giyim -> Esofman -> Erkek', '3488301469340', '4444444444444', 'Pazarama', 'Havale', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 120.43000000, 1, 0, 'Kargo', 1042.49000000, 1042.49000000, 1146.74000000, 0.00000000, 65.51000000, 947.72000000, 0.00000000, '7076697228', '2026-05-11 22:30:04'),
(138, '4450557256_4495976542', '4450557256', '4495976542', 'Standart', 'N11', 'Erkek Bot', '01-AB3603-1', '7777777777777', 'Puma', 'M', 1, 1796.00000000, 10.00000000, 1632.73000000, 'Mehmet Demir', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '5418357918064119', '2025-01-21 09:00:00', 'Fiziksel', 'Gri', '4495976542', 'Ayakkabi -> Bot -> Erkek', '5110053342975', '7777777777777', 'N11', 'Havale', NULL, '0000-00-00 00:00:00', 3.00000000, 3.00000000, 1, 0, 0, 248.65000000, 1, 0, 'Kargo', 1796.00000000, 1796.00000000, 1975.60000000, 10.00000000, 63.12000000, 1632.73000000, 0.00000000, '3772179816', '2026-05-11 22:30:04'),
(139, '9878386634_2441128469', '9878386634', '2441128469', 'Standart', 'Pazarama', 'Kadin Mont', '01-AB6780-1', '1111111111111', 'New Balance', 'S', 1, 1592.74000000, 10.00000000, 1447.95000000, 'Zeynep Arslan', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '8991698466051962', '2025-01-13 05:00:00', 'Fiziksel', 'Gri', '2441128469', 'Giyim -> Mont -> Kadin', '2611237338354', '1111111111111', 'Pazarama', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 146.98000000, 1, 0, 'Kargo', 1592.74000000, 1592.74000000, 1752.01000000, 15.00000000, 143.94000000, 1447.95000000, 0.00000000, '1669865339', '2026-05-11 22:30:04'),
(140, '6167412646_5541489317', '6167412646', '5541489317', 'Standart', 'Amazon', 'Kadin Mont', '01-AB3377-1', '1111111111111', 'Hummel', 'XL', 1, 2386.79000000, 10.00000000, 2169.81000000, 'Fatma Celik', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '2452140367523470', '2025-01-19 00:00:00', 'Fiziksel', 'Siyah', '5541489317', 'Giyim -> Mont -> Kadin', '5419772990927', '1111111111111', 'Amazon', 'Havale', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 279.54000000, 1, 0, 'Kargo', 2386.79000000, 2386.79000000, 2625.47000000, 5.00000000, 33.56000000, 2169.81000000, 0.00000000, '8822145110', '2026-05-11 22:30:04'),
(141, '1416831571_8117274356', '1416831571', '8117274356', 'Standart', 'Hepsiburada', 'Kadin Sweatshirt', '01-AB8296-1', '9999999999999', 'Hummel', '41', 1, 841.06000000, 10.00000000, 764.60000000, 'Ahmet Yilmaz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '8015252751309334', '2025-01-14 00:00:00', 'Fiziksel', 'Siyah', '8117274356', 'Giyim -> Sweatshirt -> Kadin', '9166533880257', '9999999999999', 'Hepsiburada', 'Havale', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 121.79000000, 1, 0, 'Kargo', 841.06000000, 841.06000000, 925.17000000, 5.00000000, 35.31000000, 764.60000000, 0.00000000, '2192058649', '2026-05-11 22:30:04'),
(142, '9713184117_1466402910', '9713184117', '1466402910', 'Standart', 'Amazon', 'Erkek Esofman', '01-AB2328-1', '4444444444444', 'Columbia', '40', 1, 668.54000000, 10.00000000, 607.76000000, 'Ahmet Yilmaz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '7124611774233919', '2025-01-04 19:00:00', 'Fiziksel', 'Gri', '1466402910', 'Giyim -> Esofman -> Erkek', '6234483108373', '4444444444444', 'Amazon', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 79.81000000, 1, 0, 'Kargo', 668.54000000, 668.54000000, 735.39000000, 10.00000000, 34.41000000, 607.76000000, 0.00000000, '4682958856', '2026-05-11 22:30:04'),
(143, '6691848678_5749545769', '6691848678', '5749545769', 'Standart', 'Pazarama', 'Kadin Gunluk Ayakkabi', '01-AB4449-1', '6666666666666', 'Reebok', '40', 1, 642.84000000, 10.00000000, 584.40000000, 'Mehmet Demir', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '3583323884913316', '2024-12-19 10:00:00', 'Fiziksel', 'Beyaz', '5749545769', 'Ayakkabi -> Gunluk -> Kadin', '1657795054370', '6666666666666', 'Pazarama', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 67.24000000, 1, 0, 'Kargo', 642.84000000, 642.84000000, 707.12000000, 15.00000000, 21.51000000, 584.40000000, 0.00000000, '2474049253', '2026-05-11 22:30:04'),
(144, '6240167485_8112149990', '6240167485', '8112149990', 'Standart', 'N11', 'Kadin Mont', '01-AB7564-1', '1111111111111', 'Reebok', 'S', 1, 2884.30000000, 10.00000000, 2622.09000000, 'Fatma Celik', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '6422556379145347', '2024-12-02 01:00:00', 'Fiziksel', 'Siyah', '8112149990', 'Giyim -> Mont -> Kadin', '4803899834825', '1111111111111', 'N11', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 239.15000000, 1, 0, 'Kargo', 2884.30000000, 2884.30000000, 3172.73000000, 10.00000000, 199.76000000, 2622.09000000, 0.00000000, '6327718852', '2026-05-11 22:30:04'),
(145, '4131792082_2744121574', '4131792082', '2744121574', 'Standart', 'Hepsiburada', 'Unisex Ceket', '01-AB7971-1', '8888888888888', 'Nike', 'S', 1, 1560.90000000, 10.00000000, 1419.00000000, 'Ahmet Yilmaz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '7682418339884821', '2024-12-10 23:00:00', 'Fiziksel', 'Gri', '2744121574', 'Giyim -> Ceket -> Unisex', '6105173069899', '8888888888888', 'Hepsiburada', 'Havale', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 171.19000000, 1, 0, 'Kargo', 1560.90000000, 1560.90000000, 1716.99000000, 5.00000000, 28.38000000, 1419.00000000, 0.00000000, '1328036110', '2026-05-11 22:30:04'),
(146, '8728616120_3126313771', '8728616120', '3126313771', 'Standart', 'Hepsiburada', 'Kadin Mont', '01-AB8213-1', '1111111111111', 'Adidas', 'M', 1, 2484.23000000, 10.00000000, 2258.39000000, 'Fatma Celik', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '9777377004188849', '2025-01-25 19:00:00', 'Fiziksel', 'Kirmizi', '3126313771', 'Giyim -> Mont -> Kadin', '9286076965475', '1111111111111', 'Hepsiburada', 'Havale', NULL, '0000-00-00 00:00:00', 1.00000000, 1.00000000, 1, 0, 0, 285.29000000, 1, 0, 'Kargo', 2484.23000000, 2484.23000000, 2732.65000000, 5.00000000, 19.90000000, 2258.39000000, 0.00000000, '6630686916', '2026-05-11 22:30:04'),
(147, '9012499953_8844676910', '9012499953', '8844676910', 'Standart', 'LCW', 'Erkek Bot', '01-AB5874-1', '7777777777777', 'Nike', '42', 1, 1673.57000000, 10.00000000, 1521.43000000, 'Ayse Kaya', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Teslim Edildi', '7414174809350804', '2024-12-22 00:00:00', 'Fiziksel', 'Gri', '8844676910', 'Ayakkabi -> Bot -> Erkek', '2909647182153', '7777777777777', 'LCW', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 3.00000000, 3.00000000, 1, 0, 0, 245.71000000, 1, 0, 'Kargo', 1673.57000000, 1673.57000000, 1840.93000000, 0.00000000, 38.43000000, 1521.43000000, 0.00000000, '3899452354', '2026-05-11 22:30:04'),
(148, '2533792104_4932231478', '2533792104', '4932231478', 'Standart', 'Pazarama', 'Unisex Ceket', '01-AB1073-1', '8888888888888', 'Adidas', '38', 1, 1005.20000000, 10.00000000, 913.82000000, 'Ayse Kaya', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Hazirlaniyor', '3728798378753923', '2024-12-28 07:00:00', 'Fiziksel', 'Gri', '4932231478', 'Giyim -> Ceket -> Unisex', '4509255471969', '8888888888888', 'Pazarama', 'Kredi Karti', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 143.61000000, 1, 0, 'Kargo', 1005.20000000, 1005.20000000, 1105.72000000, 10.00000000, 12.71000000, 913.82000000, 0.00000000, '1869895166', '2026-05-11 22:30:04'),
(149, '5379456756_5337292042', '5379456756', '5337292042', 'Standart', 'Pazarama', 'Kadin Gunluk Ayakkabi', '01-AB8787-1', '6666666666666', 'Puma', '38', 1, 582.68000000, 10.00000000, 529.71000000, 'Ahmet Yilmaz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Hazirlaniyor', '6523976848595538', '2024-12-06 18:00:00', 'Fiziksel', 'Siyah', '5337292042', 'Ayakkabi -> Gunluk -> Kadin', '7471846142772', '6666666666666', 'Pazarama', 'Havale', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 61.71000000, 1, 0, 'Kargo', 582.68000000, 582.68000000, 640.95000000, 5.00000000, 16.70000000, 529.71000000, 0.00000000, '2060337738', '2026-05-11 22:30:04'),
(150, '4243288997_1328778132', '4243288997', '1328778132', 'Standart', 'Hepsiburada', 'Unisex Ceket', '01-AB2632-1', '8888888888888', 'New Balance', 'XL', 1, 1621.19000000, 10.00000000, 1473.81000000, 'Ayse Kaya', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '4534307681003406', '2025-01-16 20:00:00', 'Fiziksel', 'Beyaz', '1328778132', 'Giyim -> Ceket -> Unisex', '7325175221764', '8888888888888', 'Hepsiburada', 'Havale', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 132.57000000, 1, 0, 'Kargo', 1621.19000000, 1621.19000000, 1783.31000000, 10.00000000, 110.38000000, 1473.81000000, 0.00000000, '7725025126', '2026-05-11 22:30:04'),
(151, '3079453749_7750652081', '3079453749', '7750652081', 'Standart', 'Trendyol', 'Erkek Esofman', '01-AB5092-1', '4444444444444', 'Columbia', 'M', 1, 1002.55000000, 10.00000000, 911.41000000, 'Ahmet Yilmaz', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Kargoda', '1667136092136692', '2024-12-30 16:00:00', 'Fiziksel', 'Kirmizi', '7750652081', 'Giyim -> Esofman -> Erkek', '3593389932509', '4444444444444', 'Trendyol', 'Havale', NULL, '0000-00-00 00:00:00', 2.00000000, 2.00000000, 1, 0, 0, 146.81000000, 1, 0, 'Kargo', 1002.55000000, 1002.55000000, 1102.81000000, 0.00000000, 97.29000000, 911.41000000, 0.00000000, '6905336000', '2026-05-11 22:30:04');

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Hepsiburada kargo desi fiyatlari';

--
-- Tablo döküm verisi `hepsiburada_kargo_desi_fiyatlari`
--

INSERT INTO `hepsiburada_kargo_desi_fiyatlari` (`id`, `desi`, `hepsijet`, `aras_kargo`, `mng_kargo`, `yurtici_kargo`, `surat_kargo`, `sendeo`, `ptt_kargo`, `hepsijet_xl`, `horoz_lojistik`, `ceva_lojistik`, `borusan_lojistik`, `gecerlilik_tarihi`, `olusturma_tarihi`) VALUES
(1, 1.00000000, 45.36000000, 48.99000000, 53.99000000, 67.69000000, 48.26000000, 49.80000000, 54.54000000, 289.90000000, 263.45000000, 423.12000000, 335.21000000, '2026-05-12', '2026-05-12 21:05:39'),
(2, 2.00000000, 51.25680000, 55.35870000, 61.00870000, 76.48970000, 54.53380000, 56.27400000, 61.63020000, 327.58700000, 297.69850000, 478.12560000, 378.78730000, '2026-05-12', '2026-05-12 21:05:39'),
(3, 3.00000000, 57.92020000, 62.55530000, 68.93980000, 86.43340000, 61.62320000, 63.58960000, 69.64210000, 370.17330000, 336.39930000, 540.28190000, 428.02960000, '2026-05-12', '2026-05-12 21:05:39'),
(4, 4.00000000, 65.44980000, 70.68750000, 77.90200000, 97.66970000, 69.63420000, 71.85630000, 78.69560000, 418.29580000, 380.13120000, 610.51860000, 483.67350000, '2026-05-12', '2026-05-12 21:05:39'),
(5, 5.00000000, 73.95830000, 79.87690000, 88.02930000, 110.36680000, 78.68670000, 81.19760000, 88.92600000, 472.67430000, 429.54830000, 689.88600000, 546.55110000, '2026-05-12', '2026-05-12 21:05:39');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `hitit_iadeler`
--

DROP TABLE IF EXISTS `hitit_iadeler`;
CREATE TABLE IF NOT EXISTS `hitit_iadeler` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `satis_yeri_kodu` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `satis_yeri_adi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `zaman` datetime DEFAULT NULL,
  `gider_pusulasi_tarihi` date DEFAULT NULL,
  `ozel_kod_1` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `ozel_kod_2` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `son_guncelleyen` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `iade_fatura_sistem_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `iade_fatura_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Eslesme anahtari',
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `barkod` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Eslesme anahtari',
  `urun_tutari_kdvsiz` decimal(20,8) DEFAULT NULL,
  `urun_kdv_tutari` decimal(20,8) DEFAULT NULL,
  `urun_tutari_kdvli` decimal(20,8) DEFAULT NULL,
  `urun_adedi` smallint DEFAULT NULL,
  `iade_fatura_tarihi` date DEFAULT NULL,
  `stok_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `marka` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `musteri_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `musteri_adi_soyadi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `iade_sistem_numarasi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `eticaret_web_adresi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Hangi pazaryeri',
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_hitit_i_siparis` (`siparis_no`),
  KEY `idx_hitit_i_takip` (`takip_no`),
  KEY `idx_hitit_i_barkod` (`barkod`),
  KEY `idx_hitit_i_tarih` (`iade_fatura_tarihi`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Hitit ERP iade kayitlari';

--
-- Tablo döküm verisi `hitit_iadeler`
--

INSERT INTO `hitit_iadeler` (`id`, `satis_yeri_kodu`, `satis_yeri_adi`, `zaman`, `gider_pusulasi_tarihi`, `ozel_kod_1`, `ozel_kod_2`, `son_guncelleyen`, `iade_fatura_sistem_no`, `iade_fatura_no`, `siparis_no`, `takip_no`, `barkod`, `urun_tutari_kdvsiz`, `urun_kdv_tutari`, `urun_tutari_kdvli`, `urun_adedi`, `iade_fatura_tarihi`, `stok_kodu`, `marka`, `musteri_kodu`, `musteri_adi_soyadi`, `iade_sistem_numarasi`, `eticaret_web_adresi`, `olusturma_tarihi`) VALUES
(1, '2', 'x', '2024-12-01 19:18:07', '2024-12-01', '8567353835', '365819191790258', 'x', '3699848', '74632165587_74563213827', '74563213827', '74632165587', '1450143643987', 1986.36000000, 213.64000000, 1986.00000000, 1, '2024-12-01', '100202245', '02', 'XZ1915436', 'x', '4319963', 'x', '2026-05-10 22:10:52');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `hitit_satislar`
--

DROP TABLE IF EXISTS `hitit_satislar`;
CREATE TABLE IF NOT EXISTS `hitit_satislar` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `satis_yeri_kodu` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `satis_yeri_adi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `belge_takip_no` varchar(200) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Ham — takip_no_siparis_no birlesik',
  `takip_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Ayristirilan takip no',
  `siparis_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Ayristirilan siparis no',
  `zaman` datetime DEFAULT NULL,
  `fatura_no` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `ozel_kod_1` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `ozel_kod_2` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `son_guncelleyen` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `barkod` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Eslesme anahtari',
  `urun_tutari_kdvsiz` decimal(20,8) DEFAULT NULL,
  `urun_kdv_tutari` decimal(20,8) DEFAULT NULL,
  `urun_tutari_kdvli` decimal(20,8) DEFAULT NULL,
  `urun_adedi` smallint DEFAULT NULL,
  `satis_fatura_tarihi` date DEFAULT NULL,
  `stok_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `marka` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `musteri_kodu` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `musteri_adi_soyadi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `satis_sistem_numarasi` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Pazaryeri siparis no',
  `eticaret_web_adresi` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Hangi pazaryeri',
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_hitit_s_takip` (`takip_no`),
  KEY `idx_hitit_s_siparis` (`siparis_no`),
  KEY `idx_hitit_s_barkod` (`barkod`),
  KEY `idx_hitit_s_tarih` (`satis_fatura_tarihi`)
) ENGINE=InnoDB AUTO_INCREMENT=152 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Hitit ERP satis kayitlari';

--
-- Tablo döküm verisi `hitit_satislar`
--

INSERT INTO `hitit_satislar` (`id`, `satis_yeri_kodu`, `satis_yeri_adi`, `belge_takip_no`, `takip_no`, `siparis_no`, `zaman`, `fatura_no`, `ozel_kod_1`, `ozel_kod_2`, `son_guncelleyen`, `barkod`, `urun_tutari_kdvsiz`, `urun_kdv_tutari`, `urun_tutari_kdvli`, `urun_adedi`, `satis_fatura_tarihi`, `stok_kodu`, `marka`, `musteri_kodu`, `musteri_adi_soyadi`, `satis_sistem_numarasi`, `eticaret_web_adresi`, `olusturma_tarihi`) VALUES
(102, '2', 'Hepsiburada', '4264675742_7723457100', '4264675742', '7723457100', '2024-12-24 03:00:00', 'ABC2024821254732', '7723457100', '1095216385143144', 'admin', '1010101010101', 446.74000000, 89.35000000, 536.09000000, 1, '2024-12-24', '93213166', 'Nike', 'MUS8190570', 'Fatma Celik', '6615447', 'Hepsiburada', '2026-05-11 22:30:14'),
(103, '7', 'Amazon', '1849684983_6651704635', '1849684983', '6651704635', '2025-01-10 20:00:00', 'ABC2024800685153', '6651704635', '8415365439201220', 'admin', '2222222222222', 171.40000000, 34.28000000, 205.68000000, 1, '2025-01-10', '20189193', 'Hummel', 'MUS7268928', 'Ali Oz', '4586288', 'Amazon', '2026-05-11 22:30:14'),
(104, '2', 'Hepsiburada', '6732988898_5924867347', '6732988898', '5924867347', '2025-01-05 17:00:00', 'ABC2024699840927', '5924867347', '8370326443892621', 'admin', '8888888888888', 1141.06000000, 228.21000000, 1369.27000000, 1, '2025-01-05', '69929580', 'Nike', 'MUS7731689', 'Ali Oz', '9777711', 'Hepsiburada', '2026-05-11 22:30:14'),
(105, '2', 'Hepsiburada', '6728200490_6702496208', '6728200490', '6702496208', '2025-01-29 16:00:00', 'ABC2024020489069', '6702496208', '8290305236367566', 'admin', '9999999999999', 472.17000000, 94.43000000, 566.60000000, 1, '2025-01-29', '57024048', 'Columbia', 'MUS6688630', 'Mehmet Demir', '4444076', 'Hepsiburada', '2026-05-11 22:30:14'),
(106, '3', 'Flo', '9530351872_8386238333', '9530351872', '8386238333', '2024-12-28 06:00:00', 'ABC2024400204567', '8386238333', '9610548032164991', 'admin', '7777777777777', 1987.18000000, 397.44000000, 2384.62000000, 1, '2024-12-28', '66041139', 'Hummel', 'MUS2107754', 'Ahmet Yilmaz', '4412899', 'Flo', '2026-05-11 22:30:14'),
(107, '2', 'Hepsiburada', '8956789127_5959846295', '8956789127', '5959846295', '2025-01-12 16:00:00', 'ABC2024446561477', '5959846295', '4805013680271893', 'admin', '6666666666666', 1035.15000000, 207.03000000, 1242.18000000, 1, '2025-01-12', '81844275', 'Nike', 'MUS2926784', 'Ali Oz', '6429890', 'Hepsiburada', '2026-05-11 22:30:14'),
(108, '7', 'Amazon', '8536201600_7404552443', '8536201600', '7404552443', '2025-01-14 11:00:00', 'ABC2024402196295', '7404552443', '5129848199880470', 'admin', '8888888888888', 507.88000000, 101.58000000, 609.46000000, 1, '2025-01-14', '30243383', 'Adidas', 'MUS3502925', 'Ayse Kaya', '8727259', 'Amazon', '2026-05-11 22:30:14'),
(109, '3', 'Flo', '8367905200_2412530567', '8367905200', '2412530567', '2025-01-01 16:00:00', 'ABC2024016008508', '2412530567', '7312413335117390', 'admin', '4444444444444', 481.35000000, 96.27000000, 577.62000000, 1, '2025-01-01', '11226961', 'Columbia', 'MUS7992178', 'Ali Oz', '7947391', 'Flo', '2026-05-11 22:30:14'),
(110, '7', 'Amazon', '5621714554_2363183019', '5621714554', '2363183019', '2024-12-30 00:00:00', 'ABC2024893246807', '2363183019', '2072626812588348', 'admin', '1010101010101', 516.20000000, 103.24000000, 619.44000000, 1, '2024-12-30', '36569033', 'Columbia', 'MUS3083930', 'Ayse Kaya', '8034419', 'Amazon', '2026-05-11 22:30:14'),
(111, '1', 'Trendyol', '2782276805_3433902457', '2782276805', '3433902457', '2024-12-08 05:00:00', 'ABC2024793829880', '3433902457', '3326263907687592', 'admin', '5555555555555', 300.00000000, 60.00000000, 360.00000000, 1, '2024-12-08', '14331730', 'Puma', 'MUS7004141', 'Ahmet Yilmaz', '6126031', 'Trendyol', '2026-05-11 22:30:14'),
(112, '5', 'Pazarama', '2487054642_7354534701', '2487054642', '7354534701', '2024-12-15 17:00:00', 'ABC2024486090281', '7354534701', '1067098260751550', 'admin', '1010101010101', 822.39000000, 164.48000000, 986.87000000, 1, '2024-12-15', '72067790', 'Puma', 'MUS2932136', 'Mehmet Demir', '1502138', 'Pazarama', '2026-05-11 22:30:14'),
(113, '6', 'LCW', '9689932539_8436176325', '9689932539', '8436176325', '2024-12-22 06:00:00', 'ABC2024573132877', '8436176325', '1106274656693706', 'admin', '6666666666666', 1182.73000000, 236.55000000, 1419.28000000, 1, '2024-12-22', '36688535', 'Adidas', 'MUS2917924', 'Zeynep Arslan', '7725437', 'LCW', '2026-05-11 22:30:14'),
(114, '5', 'Pazarama', '4621997119_9933534951', '4621997119', '9933534951', '2025-01-08 19:00:00', 'ABC2024064016103', '9933534951', '2370105757313036', 'admin', '9999999999999', 691.61000000, 138.32000000, 829.93000000, 1, '2025-01-08', '18944613', 'Puma', 'MUS3051392', 'Fatma Celik', '5415490', 'Pazarama', '2026-05-11 22:30:14'),
(115, '1', 'Trendyol', '5130758810_1499895106', '5130758810', '1499895106', '2025-01-30 09:00:00', 'ABC2024564582370', '1499895106', '5090653447360516', 'admin', '8888888888888', 1273.63000000, 254.73000000, 1528.36000000, 1, '2025-01-30', '87683723', 'New Balance', 'MUS6838452', 'Ahmet Yilmaz', '5586987', 'Trendyol', '2026-05-11 22:30:14'),
(116, '1', 'Trendyol', '5366495917_9255677709', '5366495917', '9255677709', '2024-12-18 17:00:00', 'ABC2024282626184', '9255677709', '2675476447762332', 'admin', '4444444444444', 334.62000000, 66.92000000, 401.54000000, 1, '2024-12-18', '85338529', 'Puma', 'MUS2388571', 'Mehmet Demir', '3745152', 'Trendyol', '2026-05-11 22:30:14'),
(117, '4', 'N11', '9144908062_7456056141', '9144908062', '7456056141', '2025-01-17 15:00:00', 'ABC2024512019597', '7456056141', '6409026445911970', 'admin', '1010101010101', 276.30000000, 55.26000000, 331.56000000, 1, '2025-01-17', '36680097', 'Adidas', 'MUS6785833', 'Ayse Kaya', '6948227', 'N11', '2026-05-11 22:30:14'),
(118, '6', 'LCW', '5754358846_5035679972', '5754358846', '5035679972', '2025-01-17 20:00:00', 'ABC2024285281219', '5035679972', '6183649503668691', 'admin', '4444444444444', 635.60000000, 127.12000000, 762.72000000, 1, '2025-01-17', '14996463', 'Adidas', 'MUS1637605', 'Mehmet Demir', '2795328', 'LCW', '2026-05-11 22:30:14'),
(119, '5', 'Pazarama', '6988511535_8738494786', '6988511535', '8738494786', '2024-12-31 06:00:00', 'ABC2024641713703', '8738494786', '8203320132477303', 'admin', '8888888888888', 524.76000000, 104.95000000, 629.71000000, 1, '2024-12-31', '79761103', 'Hummel', 'MUS8367376', 'Mehmet Demir', '3117163', 'Pazarama', '2026-05-11 22:30:14'),
(120, '3', 'Flo', '3804090187_2204481679', '3804090187', '2204481679', '2024-12-13 07:00:00', 'ABC2024189463017', '2204481679', '3214349287383176', 'admin', '6666666666666', 753.45000000, 150.69000000, 904.14000000, 1, '2024-12-13', '32730798', 'Adidas', 'MUS7196884', 'Ali Oz', '4577160', 'Flo', '2026-05-11 22:30:14'),
(121, '6', 'LCW', '4104423785_3838220535', '4104423785', '3838220535', '2024-12-11 17:00:00', 'ABC2024483391301', '3838220535', '6443435993443519', 'admin', '7777777777777', 1866.42000000, 373.28000000, 2239.70000000, 1, '2024-12-11', '71988248', 'Nike', 'MUS4843556', 'Mehmet Demir', '1858278', 'LCW', '2026-05-11 22:30:14'),
(122, '6', 'LCW', '5146868116_5696995250', '5146868116', '5696995250', '2025-01-10 05:00:00', 'ABC2024152942421', '5696995250', '4507202258732542', 'admin', '3333333333333', 614.27000000, 122.85000000, 737.12000000, 1, '2025-01-10', '70477735', 'Adidas', 'MUS1917661', 'Ali Oz', '6219732', 'LCW', '2026-05-11 22:30:14'),
(123, '7', 'Amazon', '1919867916_6587697097', '1919867916', '6587697097', '2025-01-23 01:00:00', 'ABC2024598821596', '6587697097', '7998463026971421', 'admin', '1111111111111', 1710.72000000, 342.14000000, 2052.86000000, 1, '2025-01-23', '94916440', 'New Balance', 'MUS5625225', 'Ayse Kaya', '9723792', 'Amazon', '2026-05-11 22:30:14'),
(124, '1', 'Trendyol', '1327389376_6757376373', '1327389376', '6757376373', '2025-01-02 11:00:00', 'ABC2024650937307', '6757376373', '1084984258825602', 'admin', '5555555555555', 710.37000000, 142.07000000, 852.44000000, 1, '2025-01-02', '60165484', 'Reebok', 'MUS7245928', 'Ahmet Yilmaz', '1526769', 'Trendyol', '2026-05-11 22:30:14'),
(125, '5', 'Pazarama', '2671749205_9123547824', '2671749205', '9123547824', '2024-12-05 03:00:00', 'ABC2024000733871', '9123547824', '8931221899582856', 'admin', '3333333333333', 485.61000000, 97.12000000, 582.73000000, 1, '2024-12-05', '44460780', 'Nike', 'MUS2312818', 'Zeynep Arslan', '9657919', 'Pazarama', '2026-05-11 22:30:14'),
(126, '4', 'N11', '7974106541_5516173473', '7974106541', '5516173473', '2025-01-06 03:00:00', 'ABC2024108521499', '5516173473', '1249163116729265', 'admin', '7777777777777', 661.88000000, 132.38000000, 794.26000000, 1, '2025-01-06', '91825992', 'Adidas', 'MUS4423548', 'Ayse Kaya', '2698803', 'N11', '2026-05-11 22:30:14'),
(127, '1', 'Trendyol', '4670271555_1775628967', '4670271555', '1775628967', '2025-01-20 13:00:00', 'ABC2024227748606', '1775628967', '9245568487799581', 'admin', '8888888888888', 981.62000000, 196.32000000, 1177.94000000, 1, '2025-01-20', '72114734', 'Columbia', 'MUS2449261', 'Fatma Celik', '3073244', 'Trendyol', '2026-05-11 22:30:14'),
(128, '6', 'LCW', '9340182226_3462668187', '9340182226', '3462668187', '2024-12-03 11:00:00', 'ABC2024617178881', '3462668187', '9807154109197495', 'admin', '3333333333333', 1633.53000000, 326.71000000, 1960.24000000, 1, '2024-12-03', '43183673', 'Puma', 'MUS7718081', 'Zeynep Arslan', '8930196', 'LCW', '2026-05-11 22:30:14'),
(129, '7', 'Amazon', '8902659967_6751878730', '8902659967', '6751878730', '2025-01-24 08:00:00', 'ABC2024460838367', '6751878730', '2026234371679527', 'admin', '7777777777777', 953.34000000, 190.67000000, 1144.01000000, 1, '2025-01-24', '61277367', 'Nike', 'MUS7066062', 'Zeynep Arslan', '6470414', 'Amazon', '2026-05-11 22:30:14'),
(130, '4', 'N11', '3596800447_9735009373', '3596800447', '9735009373', '2024-12-03 18:00:00', 'ABC2024558765695', '9735009373', '8848042300857421', 'admin', '9999999999999', 479.59000000, 95.92000000, 575.51000000, 1, '2024-12-03', '77138340', 'Nike', 'MUS8213787', 'Ahmet Yilmaz', '2390562', 'N11', '2026-05-11 22:30:14'),
(131, '1', 'Trendyol', '1739120892_9116101879', '1739120892', '9116101879', '2025-01-14 09:00:00', 'ABC2024438483631', '9116101879', '1910498396191027', 'admin', '6666666666666', 1418.13000000, 283.63000000, 1701.76000000, 1, '2025-01-14', '97286540', 'Puma', 'MUS6883676', 'Fatma Celik', '2437176', 'Trendyol', '2026-05-11 22:30:14'),
(132, '6', 'LCW', '7961805572_3699356126', '7961805572', '3699356126', '2024-12-26 09:00:00', 'ABC2024428350672', '3699356126', '7128465032292766', 'admin', '1010101010101', 438.00000000, 87.60000000, 525.60000000, 1, '2024-12-26', '46239100', 'Nike', 'MUS3240005', 'Fatma Celik', '3305048', 'LCW', '2026-05-11 22:30:14'),
(133, '3', 'Flo', '2688521890_8541990551', '2688521890', '8541990551', '2024-12-30 06:00:00', 'ABC2024893014256', '8541990551', '4933066846898871', 'admin', '1010101010101', 787.98000000, 157.60000000, 945.58000000, 1, '2024-12-30', '69654046', 'Nike', 'MUS5787366', 'Ahmet Yilmaz', '2819309', 'Flo', '2026-05-11 22:30:14'),
(134, '1', 'Trendyol', '5364362201_5841159565', '5364362201', '5841159565', '2024-12-07 04:00:00', 'ABC2024501894298', '5841159565', '5887329173963536', 'admin', '1111111111111', 2302.40000000, 460.48000000, 2762.88000000, 1, '2024-12-07', '56682736', 'Columbia', 'MUS5378483', 'Mehmet Demir', '6101857', 'Trendyol', '2026-05-11 22:30:14'),
(135, '6', 'LCW', '2130386388_8370246835', '2130386388', '8370246835', '2025-01-27 03:00:00', 'ABC2024830880369', '8370246835', '4970086283222749', 'admin', '2222222222222', 315.26000000, 63.05000000, 378.31000000, 1, '2025-01-27', '20917399', 'Reebok', 'MUS2083996', 'Fatma Celik', '2923802', 'LCW', '2026-05-11 22:30:14'),
(136, '1', 'Trendyol', '2329460683_5949192636', '2329460683', '5949192636', '2024-12-16 03:00:00', 'ABC2024678844723', '5949192636', '3130222061132229', 'admin', '9999999999999', 508.45000000, 101.69000000, 610.14000000, 1, '2024-12-16', '77158285', 'Puma', 'MUS3484531', 'Ayse Kaya', '9488109', 'Trendyol', '2026-05-11 22:30:14'),
(137, '5', 'Pazarama', '3723410016_3476439344', '3723410016', '3476439344', '2024-12-11 00:00:00', 'ABC2024995616265', '3476439344', '4677254092993133', 'admin', '4444444444444', 868.74000000, 173.75000000, 1042.49000000, 1, '2024-12-11', '43755514', 'Hummel', 'MUS1921147', 'Mehmet Demir', '5574147', 'Pazarama', '2026-05-11 22:30:14'),
(138, '4', 'N11', '4450557256_4495976542', '4450557256', '4495976542', '2025-01-21 09:00:00', 'ABC2024221620097', '4495976542', '6555452025661703', 'admin', '7777777777777', 1496.67000000, 299.33000000, 1796.00000000, 1, '2025-01-21', '48803414', 'Puma', 'MUS7087898', 'Mehmet Demir', '1296310', 'N11', '2026-05-11 22:30:14'),
(139, '5', 'Pazarama', '9878386634_2441128469', '9878386634', '2441128469', '2025-01-13 05:00:00', 'ABC2024556028427', '2441128469', '9092190240803249', 'admin', '1111111111111', 1327.28000000, 265.46000000, 1592.74000000, 1, '2025-01-13', '65905978', 'New Balance', 'MUS6374577', 'Zeynep Arslan', '2860618', 'Pazarama', '2026-05-11 22:30:14'),
(140, '7', 'Amazon', '6167412646_5541489317', '6167412646', '5541489317', '2025-01-19 00:00:00', 'ABC2024573275240', '5541489317', '9201129403573236', 'admin', '1111111111111', 1988.99000000, 397.80000000, 2386.79000000, 1, '2025-01-19', '73885441', 'Hummel', 'MUS3689282', 'Fatma Celik', '6043684', 'Amazon', '2026-05-11 22:30:14'),
(141, '2', 'Hepsiburada', '1416831571_8117274356', '1416831571', '8117274356', '2025-01-14 00:00:00', 'ABC2024267322436', '8117274356', '9757226972851140', 'admin', '9999999999999', 700.88000000, 140.18000000, 841.06000000, 1, '2025-01-14', '73322840', 'Hummel', 'MUS5679724', 'Ahmet Yilmaz', '9501978', 'Hepsiburada', '2026-05-11 22:30:14'),
(142, '7', 'Amazon', '9713184117_1466402910', '9713184117', '1466402910', '2025-01-04 19:00:00', 'ABC2024052337742', '1466402910', '2168885219158152', 'admin', '4444444444444', 557.12000000, 111.42000000, 668.54000000, 1, '2025-01-04', '14861780', 'Columbia', 'MUS9186810', 'Ahmet Yilmaz', '6807945', 'Amazon', '2026-05-11 22:30:14'),
(143, '5', 'Pazarama', '6691848678_5749545769', '6691848678', '5749545769', '2024-12-19 10:00:00', 'ABC2024163443903', '5749545769', '9955663414436846', 'admin', '6666666666666', 535.70000000, 107.14000000, 642.84000000, 1, '2024-12-19', '28810190', 'Reebok', 'MUS8927686', 'Mehmet Demir', '7619110', 'Pazarama', '2026-05-11 22:30:14'),
(144, '4', 'N11', '6240167485_8112149990', '6240167485', '8112149990', '2024-12-02 01:00:00', 'ABC2024277553949', '8112149990', '7429546640911245', 'admin', '1111111111111', 2403.58000000, 480.72000000, 2884.30000000, 1, '2024-12-02', '76562587', 'Reebok', 'MUS2946800', 'Fatma Celik', '3088209', 'N11', '2026-05-11 22:30:14'),
(145, '2', 'Hepsiburada', '4131792082_2744121574', '4131792082', '2744121574', '2024-12-10 23:00:00', 'ABC2024940094722', '2744121574', '5150516604768381', 'admin', '8888888888888', 1300.75000000, 260.15000000, 1560.90000000, 1, '2024-12-10', '40071117', 'Nike', 'MUS8249277', 'Ahmet Yilmaz', '5044817', 'Hepsiburada', '2026-05-11 22:30:14'),
(146, '2', 'Hepsiburada', '8728616120_3126313771', '8728616120', '3126313771', '2025-01-25 19:00:00', 'ABC2024160760288', '3126313771', '7013158100508675', 'admin', '1111111111111', 2070.19000000, 414.04000000, 2484.23000000, 1, '2025-01-25', '73896104', 'Adidas', 'MUS3058480', 'Fatma Celik', '5231545', 'Hepsiburada', '2026-05-11 22:30:14'),
(147, '6', 'LCW', '9012499953_8844676910', '9012499953', '8844676910', '2024-12-22 00:00:00', 'ABC2024641586149', '8844676910', '7790513858596211', 'admin', '7777777777777', 1394.64000000, 278.93000000, 1673.57000000, 1, '2024-12-22', '88009989', 'Nike', 'MUS3248663', 'Ayse Kaya', '4233297', 'LCW', '2026-05-11 22:30:14'),
(148, '5', 'Pazarama', '2533792104_4932231478', '2533792104', '4932231478', '2024-12-28 07:00:00', 'ABC2024682442043', '4932231478', '9759458439826585', 'admin', '8888888888888', 837.67000000, 167.53000000, 1005.20000000, 1, '2024-12-28', '44373002', 'Adidas', 'MUS4434291', 'Ayse Kaya', '5416044', 'Pazarama', '2026-05-11 22:30:14'),
(149, '5', 'Pazarama', '5379456756_5337292042', '5379456756', '5337292042', '2024-12-06 18:00:00', 'ABC2024465451426', '5337292042', '9425318659191383', 'admin', '6666666666666', 485.57000000, 97.11000000, 582.68000000, 1, '2024-12-06', '63056842', 'Puma', 'MUS7514136', 'Ahmet Yilmaz', '7528402', 'Pazarama', '2026-05-11 22:30:14'),
(150, '2', 'Hepsiburada', '4243288997_1328778132', '4243288997', '1328778132', '2025-01-16 20:00:00', 'ABC2024566718188', '1328778132', '3861328818045731', 'admin', '8888888888888', 1350.99000000, 270.20000000, 1621.19000000, 1, '2025-01-16', '13195201', 'New Balance', 'MUS3595133', 'Ayse Kaya', '7716189', 'Hepsiburada', '2026-05-11 22:30:14'),
(151, '1', 'Trendyol', '3079453749_7750652081', '3079453749', '7750652081', '2024-12-30 16:00:00', 'ABC2024916676053', '7750652081', '8375867580276477', 'admin', '4444444444444', 835.46000000, 167.09000000, 1002.55000000, 1, '2024-12-30', '46677374', 'Columbia', 'MUS4429561', 'Ahmet Yilmaz', '4298198', 'Trendyol', '2026-05-11 22:30:14');

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
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Son tablo — karlilik ozeti ve mutabakat';

--
-- Tablo döküm verisi `karlilik_ozeti`
--

INSERT INTO `karlilik_ozeti` (`id`, `siparis_id`, `siparis_no`, `pazaryeri_siparis_no`, `takip_no`, `barkod`, `urun_adi`, `pazaryeri`, `siparis_durumu`, `siparis_tarihi`, `ulke`, `kdv_orani`, `kategori`, `siparis_adeti`, `birim_fiyat`, `siparis_toplam_tutari`, `pazaryeri_fiyati`, `satis_adeti`, `satis_tipi`, `satis_tutari`, `satis_iade_adedi`, `satis_iade_tutari`, `iade_iptal_adedi`, `iade_iptal_tutari`, `tahmini_desi`, `hesaplanan_siparis_desisi`, `hesaplanan_siparis_desi_tutari`, `faturalanan_desi_tutari`, `faturalanan_desi`, `hesaplanan_komisyon_tutari`, `faturalanan_komisyon_tutari`, `faturalanan_iade_komisyonu`, `urun_maliyeti`, `kargo_maliyeti`, `satis_kargosu`, `iade_kargosu`, `stopaj`, `stopaj_iadesi`, `tedarik_edememe`, `gecikme_cezasi`, `yanlis_urun`, `kusurlu_urun`, `eksik_urun`, `kupon`, `kampanya_indirimi`, `pazarlama_hizmet_bedeli`, `platform_hizmet_bedeli`, `reklam_gideri`, `diger_kesintiler`, `net_gelir`, `net_kar`, `kar_marji`, `zarar_mi`, `mutabakat_durumu`, `mukrerrer_mi`, `fark_var_mi`, `iade_komisyon_dogru_mu`, `odeme_farki`, `son_hesaplama_tarihi`) VALUES
(5, 102, '7723457100', '7723457100', NULL, '1010101010101', 'Canta', 'Hepsiburada', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 536.09000000, 536.09000000, 1, NULL, 536.09000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 51.13000000, NULL, 446.74000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 484.96000000, 38.22000000, 7.12939991, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(6, 103, '6651704635', '6651704635', NULL, '2222222222222', 'Erkek Tisort', 'Amazon', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 205.68000000, 205.68000000, 1, NULL, 205.68000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 19.74000000, NULL, 171.40000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 185.94000000, 14.54000000, 7.06923376, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(7, 104, '5924867347', '5924867347', NULL, '8888888888888', 'Unisex Ceket', 'Hepsiburada', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1369.27000000, 1369.27000000, 1, NULL, 1369.27000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 173.42000000, NULL, 1141.06000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1195.85000000, 54.79000000, 4.00140221, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(8, 105, '6702496208', '6702496208', NULL, '9999999999999', 'Kadin Sweatshirt', 'Hepsiburada', 'Hazirlaniyor', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 566.60000000, 566.60000000, 1, NULL, 566.60000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 74.38000000, NULL, 472.17000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 492.22000000, 20.05000000, 3.53865161, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(9, 106, '8386238333', '8386238333', NULL, '7777777777777', 'Erkek Bot', 'Flo', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 2384.62000000, 2384.62000000, 1, NULL, 2384.62000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 229.56000000, NULL, 1987.18000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2155.06000000, 167.88000000, 7.04011541, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(10, 107, '5959846295', '5959846295', NULL, '6666666666666', 'Kadin Gunluk Ayakkabi', 'Hepsiburada', 'Hazirlaniyor', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1242.18000000, 1242.18000000, 1, NULL, 1242.18000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 149.26000000, NULL, 1035.15000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1092.92000000, 57.77000000, 4.65069475, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(11, 108, '7404552443', '7404552443', NULL, '8888888888888', 'Unisex Ceket', 'Amazon', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 609.46000000, 609.46000000, 1, NULL, 609.46000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 79.77000000, NULL, 507.88000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 529.69000000, 21.81000000, 3.57857776, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(12, 109, '2412530567', '2412530567', NULL, '4444444444444', 'Erkek Esofman', 'Flo', 'Hazirlaniyor', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 577.62000000, 577.62000000, 1, NULL, 577.62000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 86.23000000, NULL, 481.35000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 491.39000000, 10.04000000, 1.73816696, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(13, 110, '2363183019', '2363183019', NULL, '1010101010101', 'Canta', 'Amazon', 'Hazirlaniyor', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 619.44000000, 619.44000000, 1, NULL, 619.44000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 63.54000000, NULL, 516.20000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 555.90000000, 39.70000000, 6.40901459, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(14, 111, '3433902457', '3433902457', NULL, '5555555555555', 'Kadin Elbise', 'Trendyol', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 360.00000000, 360.00000000, 1, NULL, 360.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 36.94000000, NULL, 300.00000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 323.06000000, 23.06000000, 6.40555556, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(15, 112, '7354534701', '7354534701', NULL, '1010101010101', 'Canta', 'Pazarama', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 986.87000000, 986.87000000, 1, NULL, 986.87000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 115.94000000, NULL, 822.39000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 870.93000000, 48.54000000, 4.91858097, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(16, 113, '8436176325', '8436176325', NULL, '6666666666666', 'Kadin Gunluk Ayakkabi', 'LCW', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1419.28000000, 1419.28000000, 1, NULL, 1419.28000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 190.27000000, NULL, 1182.73000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1229.01000000, 46.28000000, 3.26080830, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(17, 114, '9933534951', '9933534951', NULL, '9999999999999', 'Kadin Sweatshirt', 'Pazarama', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 829.93000000, 829.93000000, 1, NULL, 829.93000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 87.64000000, NULL, 691.61000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 742.29000000, 50.68000000, 6.10653911, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(18, 115, '1499895106', '1499895106', NULL, '8888888888888', 'Unisex Ceket', 'Trendyol', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1528.36000000, 1528.36000000, 1, NULL, 1528.36000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 227.92000000, NULL, 1273.63000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1300.44000000, 26.81000000, 1.75416787, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(19, 116, '9255677709', '9255677709', NULL, '4444444444444', 'Erkek Esofman', 'Trendyol', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 401.54000000, 401.54000000, 1, NULL, 401.54000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 51.26000000, NULL, 334.62000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 350.28000000, 15.66000000, 3.89998506, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(20, 117, '7456056141', '7456056141', NULL, '1010101010101', 'Canta', 'N11', 'Hazirlaniyor', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 331.56000000, 331.56000000, 1, NULL, 331.56000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 37.41000000, NULL, 276.30000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 294.15000000, 17.85000000, 5.38364097, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(21, 118, '5035679972', '5035679972', NULL, '4444444444444', 'Erkek Esofman', 'LCW', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 762.72000000, 762.72000000, 1, NULL, 762.72000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 68.30000000, NULL, 635.60000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 694.42000000, 58.82000000, 7.71187330, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(22, 119, '8738494786', '8738494786', NULL, '8888888888888', 'Unisex Ceket', 'Pazarama', 'Hazirlaniyor', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 629.71000000, 629.71000000, 1, NULL, 629.71000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 90.08000000, NULL, 524.76000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 539.63000000, 14.87000000, 2.36140446, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(23, 120, '2204481679', '2204481679', NULL, '6666666666666', 'Kadin Gunluk Ayakkabi', 'Flo', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 904.14000000, 904.14000000, 1, NULL, 904.14000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 120.16000000, NULL, 753.45000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 783.98000000, 30.53000000, 3.37668945, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(24, 121, '3838220535', '3838220535', NULL, '7777777777777', 'Erkek Bot', 'LCW', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 2239.70000000, 2239.70000000, 1, NULL, 2239.70000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 277.85000000, NULL, 1866.42000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1961.85000000, 95.43000000, 4.26083851, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(25, 122, '5696995250', '5696995250', NULL, '3333333333333', 'Unisex Spor Ayakkabi', 'LCW', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 737.12000000, 737.12000000, 1, NULL, 737.12000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 84.47000000, NULL, 614.27000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 652.65000000, 38.38000000, 5.20675060, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(26, 123, '6587697097', '6587697097', NULL, '1111111111111', 'Kadin Mont', 'Amazon', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 2052.86000000, 2052.86000000, 1, NULL, 2052.86000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 271.62000000, NULL, 1710.72000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1781.24000000, 70.52000000, 3.43520747, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(27, 124, '6757376373', '6757376373', NULL, '5555555555555', 'Kadin Elbise', 'Trendyol', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 852.44000000, 852.44000000, 1, NULL, 852.44000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 90.47000000, NULL, 710.37000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 761.97000000, 51.60000000, 6.05321196, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(28, 125, '9123547824', '9123547824', NULL, '3333333333333', 'Unisex Spor Ayakkabi', 'Pazarama', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 582.73000000, 582.73000000, 1, NULL, 582.73000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 53.57000000, NULL, 485.61000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 529.16000000, 43.55000000, 7.47344396, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(29, 126, '5516173473', '5516173473', NULL, '7777777777777', 'Erkek Bot', 'N11', 'Hazirlaniyor', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 794.26000000, 794.26000000, 1, NULL, 794.26000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 97.57000000, NULL, 661.88000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 696.69000000, 34.81000000, 4.38269584, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(30, 127, '1775628967', '1775628967', NULL, '8888888888888', 'Unisex Ceket', 'Trendyol', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1177.94000000, 1177.94000000, 1, NULL, 1177.94000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 102.79000000, NULL, 981.62000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1075.15000000, 93.53000000, 7.94013277, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(31, 128, '3462668187', '3462668187', NULL, '3333333333333', 'Unisex Spor Ayakkabi', 'LCW', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1960.24000000, 1960.24000000, 1, NULL, 1960.24000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 220.41000000, NULL, 1633.53000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1739.83000000, 106.30000000, 5.42280537, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(32, 129, '6751878730', '6751878730', NULL, '7777777777777', 'Erkek Bot', 'Amazon', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1144.01000000, 1144.01000000, 1, NULL, 1144.01000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 135.31000000, NULL, 953.34000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1008.70000000, 55.36000000, 4.83911854, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(33, 130, '9735009373', '9735009373', NULL, '9999999999999', 'Kadin Sweatshirt', 'N11', 'Hazirlaniyor', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 575.51000000, 575.51000000, 1, NULL, 575.51000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 75.54000000, NULL, 479.59000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 499.97000000, 20.38000000, 3.54120693, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(34, 131, '9116101879', '9116101879', NULL, '6666666666666', 'Kadin Gunluk Ayakkabi', 'Trendyol', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1701.76000000, 1701.76000000, 1, NULL, 1701.76000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 219.76000000, NULL, 1418.13000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1482.00000000, 63.87000000, 3.75317319, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(35, 132, '3699356126', '3699356126', NULL, '1010101010101', 'Canta', 'LCW', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 525.60000000, 525.60000000, 1, NULL, 525.60000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 54.80000000, NULL, 438.00000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 470.80000000, 32.80000000, 6.24048706, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(36, 133, '8541990551', '8541990551', NULL, '1010101010101', 'Canta', 'Flo', 'Hazirlaniyor', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 945.58000000, 945.58000000, 1, NULL, 945.58000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 100.08000000, NULL, 787.98000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 845.50000000, 57.52000000, 6.08303898, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(37, 134, '5841159565', '5841159565', NULL, '1111111111111', 'Kadin Mont', 'Trendyol', 'Hazirlaniyor', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 2762.88000000, 2762.88000000, 1, NULL, 2762.88000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 390.61000000, NULL, 2302.40000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2372.27000000, 69.87000000, 2.52888290, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(38, 135, '8370246835', '8370246835', NULL, '2222222222222', 'Erkek Tisort', 'LCW', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 378.31000000, 378.31000000, 1, NULL, 378.31000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 54.72000000, NULL, 315.26000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 323.59000000, 8.33000000, 2.20189791, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(39, 136, '5949192636', '5949192636', NULL, '9999999999999', 'Kadin Sweatshirt', 'Trendyol', 'Hazirlaniyor', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 610.14000000, 610.14000000, 1, NULL, 610.14000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 74.41000000, NULL, 508.45000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 535.73000000, 27.28000000, 4.47110499, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(40, 137, '3476439344', '3476439344', NULL, '4444444444444', 'Erkek Esofman', 'Pazarama', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1042.49000000, 1042.49000000, 1, NULL, 1042.49000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 120.43000000, NULL, 868.74000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 922.06000000, 53.32000000, 5.11467736, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(41, 138, '4495976542', '4495976542', NULL, '7777777777777', 'Erkek Bot', 'N11', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1796.00000000, 1796.00000000, 1, NULL, 1796.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 248.65000000, NULL, 1496.67000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1547.35000000, 50.68000000, 2.82182628, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(42, 139, '2441128469', '2441128469', NULL, '1111111111111', 'Kadin Mont', 'Pazarama', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1592.74000000, 1592.74000000, 1, NULL, 1592.74000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 146.98000000, NULL, 1327.28000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1445.76000000, 118.48000000, 7.43875334, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(43, 140, '5541489317', '5541489317', NULL, '1111111111111', 'Kadin Mont', 'Amazon', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 2386.79000000, 2386.79000000, 1, NULL, 2386.79000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 279.54000000, NULL, 1988.99000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2107.25000000, 118.26000000, 4.95477189, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(44, 141, '8117274356', '8117274356', NULL, '9999999999999', 'Kadin Sweatshirt', 'Hepsiburada', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 841.06000000, 841.06000000, 1, NULL, 841.06000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 121.79000000, NULL, 700.88000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 719.27000000, 18.39000000, 2.18652653, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(45, 142, '1466402910', '1466402910', NULL, '4444444444444', 'Erkek Esofman', 'Amazon', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 668.54000000, 668.54000000, 1, NULL, 668.54000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 79.81000000, NULL, 557.12000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 588.73000000, 31.61000000, 4.72821372, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(46, 143, '5749545769', '5749545769', NULL, '6666666666666', 'Kadin Gunluk Ayakkabi', 'Pazarama', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 642.84000000, 642.84000000, 1, NULL, 642.84000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 67.24000000, NULL, 535.70000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 575.60000000, 39.90000000, 6.20683218, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(47, 144, '8112149990', '8112149990', NULL, '1111111111111', 'Kadin Mont', 'N11', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 2884.30000000, 2884.30000000, 1, NULL, 2884.30000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 239.15000000, NULL, 2403.58000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2645.15000000, 241.57000000, 8.37534237, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(48, 145, '2744121574', '2744121574', NULL, '8888888888888', 'Unisex Ceket', 'Hepsiburada', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1560.90000000, 1560.90000000, 1, NULL, 1560.90000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 171.19000000, NULL, 1300.75000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1389.71000000, 88.96000000, 5.69927606, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(49, 146, '3126313771', '3126313771', NULL, '1111111111111', 'Kadin Mont', 'Hepsiburada', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 2484.23000000, 2484.23000000, 1, NULL, 2484.23000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 285.29000000, NULL, 2070.19000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2198.94000000, 128.75000000, 5.18269242, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(50, 147, '8844676910', '8844676910', NULL, '7777777777777', 'Erkek Bot', 'LCW', 'Teslim Edildi', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1673.57000000, 1673.57000000, 1, NULL, 1673.57000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 245.71000000, NULL, 1394.64000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1427.86000000, 33.22000000, 1.98497822, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(51, 148, '4932231478', '4932231478', NULL, '8888888888888', 'Unisex Ceket', 'Pazarama', 'Hazirlaniyor', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1005.20000000, 1005.20000000, 1, NULL, 1005.20000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 143.61000000, NULL, 837.67000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 861.59000000, 23.92000000, 2.37962595, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(52, 149, '5337292042', '5337292042', NULL, '6666666666666', 'Kadin Gunluk Ayakkabi', 'Pazarama', 'Hazirlaniyor', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 582.68000000, 582.68000000, 1, NULL, 582.68000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 61.71000000, NULL, 485.57000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 520.97000000, 35.40000000, 6.07537585, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(53, 150, '1328778132', '1328778132', NULL, '8888888888888', 'Unisex Ceket', 'Hepsiburada', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1621.19000000, 1621.19000000, 1, NULL, 1621.19000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 132.57000000, NULL, 1350.99000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1488.62000000, 137.63000000, 8.48944294, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14'),
(54, 151, '7750652081', '7750652081', NULL, '4444444444444', 'Erkek Esofman', 'Trendyol', 'Kargoda', '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, 1002.55000000, 1002.55000000, 1, NULL, 1002.55000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, NULL, 146.81000000, NULL, 835.46000000, NULL, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 855.74000000, 20.28000000, 2.02284175, 0, 'beklemede', 0, 0, NULL, NULL, '2026-05-11 22:30:14');

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
  `tahmini_desi` int NOT NULL COMMENT 'Tam sayi desi degeri',
  `barkod` varchar(100) COLLATE utf8mb4_turkish_ci DEFAULT NULL COMMENT 'Barkod bazli eslestirme icin',
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tek_kategori` (`ana_kategori`,`alt_kategori`,`cinsiyet`),
  KEY `idx_desi_barkod` (`barkod`),
  KEY `idx_desi_ana` (`ana_kategori`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Kategori ve barkod bazli tahmini desi listesi';

--
-- Tablo döküm verisi `kategori_desi_listesi`
--

INSERT INTO `kategori_desi_listesi` (`id`, `ana_kategori`, `alt_kategori`, `cinsiyet`, `tahmini_desi`, `barkod`, `olusturma_tarihi`) VALUES
(1, 'Giyim', 'Mont', 'Kadin', 1, '1111111111111', '2026-05-11 21:28:48'),
(2, 'Giyim', 'Tisort', 'Erkek', 1, '2222222222222', '2026-05-11 21:28:48'),
(3, 'Ayakkabi', 'Spor', NULL, 2, '3333333333333', '2026-05-11 21:28:48'),
(4, 'Giyim', 'Esofman', 'Erkek', 2, '4444444444444', '2026-05-11 21:28:48'),
(5, 'Giyim', 'Elbise', 'Kadin', 1, '5555555555555', '2026-05-11 21:28:48'),
(6, 'Ayakkabi', 'Gunluk', 'Kadin', 2, '6666666666666', '2026-05-11 21:28:48'),
(7, 'Ayakkabi', 'Bot', 'Erkek', 3, '7777777777777', '2026-05-11 21:28:48'),
(8, 'Giyim', 'Ceket', 'Unisex', 2, '8888888888888', '2026-05-11 21:28:48'),
(9, 'Giyim', 'Sweatshirt', 'Kadin', 1, '9999999999999', '2026-05-11 21:28:48'),
(10, 'Aksesuar', 'Canta', NULL, 1, '1010101010101', '2026-05-11 21:28:48');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `komisyon_oranlari`
--

DROP TABLE IF EXISTS `komisyon_oranlari`;
CREATE TABLE IF NOT EXISTS `komisyon_oranlari` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `pazaryeri_kod` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL COMMENT 'pazaryerleri.kod ile eslesir',
  `kategori` varchar(255) COLLATE utf8mb4_turkish_ci NOT NULL COMMENT 'Giyim, Ayakkabi vb.',
  `alt_kategori` varchar(255) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `komisyon_orani` decimal(20,8) NOT NULL COMMENT 'Yuzde olarak: 12.5 = %12.5',
  `gecerlilik_tarihi` date NOT NULL DEFAULT (curdate()),
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_kom_pazaryeri` (`pazaryeri_kod`),
  KEY `idx_kom_kategori` (`kategori`),
  KEY `idx_kom_tarih` (`gecerlilik_tarihi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Pazaryeri bazli kategori komisyon oranlari';

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `kullanicilar`
--

DROP TABLE IF EXISTS `kullanicilar`;
CREATE TABLE IF NOT EXISTS `kullanicilar` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `ad` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `soyad` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_turkish_ci NOT NULL,
  `sifre_hash` varchar(255) COLLATE utf8mb4_turkish_ci NOT NULL,
  `rol` enum('admin','analist','okuyucu') COLLATE utf8mb4_turkish_ci NOT NULL DEFAULT 'okuyucu',
  `aktif_mi` tinyint(1) NOT NULL DEFAULT '1',
  `son_giris` datetime DEFAULT NULL,
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `guncelleme_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tek_email` (`email`),
  KEY `idx_rol` (`rol`),
  KEY `idx_aktif` (`aktif_mi`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Sistem kullanicilari';

--
-- Tablo döküm verisi `kullanicilar`
--

INSERT INTO `kullanicilar` (`id`, `ad`, `soyad`, `email`, `sifre_hash`, `rol`, `aktif_mi`, `son_giris`, `olusturma_tarihi`, `guncelleme_tarihi`) VALUES
(1, 'Abdulkadir', 'Çöpcü', 'abdulkadircopcu@gmail.com', '$2b$12$GlaqRcQ8NJQBc212bvSK9.dLfnZEdJDdY3GHMs5/DAlMK9OKdnpuq', 'admin', 1, '2026-05-12 20:49:10', '2026-05-10 23:17:48', '2026-05-12 20:49:10'),
(2, 'Test', 'User', 'abdulkadircopycu@gmail.com', '$2b$12$rn7B8bT0uhK/e0c5TFlkm.MWM0LcRtV.8cUj0fHbbPgM0yY2qW2ru', 'admin', 1, '2026-05-10 23:28:03', '2026-05-10 23:23:36', '2026-05-10 23:28:03');

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='LCW kargo desi fiyatlari';

--
-- Tablo döküm verisi `lcw_kargo_desi_fiyatlari`
--

INSERT INTO `lcw_kargo_desi_fiyatlari` (`id`, `desi`, `aras_kargo`, `hepsijet`, `kargoist`, `surat_kargo`, `yurtici_kargo`, `gecerlilik_tarihi`, `olusturma_tarihi`) VALUES
(1, 1.00000000, 52.29830000, 46.36500000, 34.26980000, 52.36540000, 65.32480000, '2026-05-12', '2026-05-12 21:05:39'),
(2, 2.00000000, 59.09710000, 52.39240000, 38.72490000, 59.17290000, 73.81700000, '2026-05-12', '2026-05-12 21:05:39'),
(3, 3.00000000, 66.77970000, 59.20350000, 43.75910000, 66.86540000, 83.41320000, '2026-05-12', '2026-05-12 21:05:39'),
(4, 4.00000000, 75.46110000, 66.89990000, 49.44780000, 75.55790000, 94.25700000, '2026-05-12', '2026-05-12 21:05:39'),
(5, 5.00000000, 85.27100000, 75.59690000, 55.87600000, 85.38040000, 106.51040000, '2026-05-12', '2026-05-12 21:05:39');

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='N11 kargo desi fiyatlari';

--
-- Tablo döküm verisi `n11_kargo_desi_fiyatlari`
--

INSERT INTO `n11_kargo_desi_fiyatlari` (`id`, `desi`, `aras_kargo`, `ptt_kargo`, `yurtici_kargo`, `surat_kargo`, `sendeo_kargo`, `gecerlilik_tarihi`, `olusturma_tarihi`) VALUES
(1, 1.00000000, 47.36000000, 15.30000000, 66.36000000, 48.50000000, 48.60000000, '2026-05-12', '2026-05-12 21:05:39'),
(2, 2.00000000, 53.51680000, 17.28900000, 74.98680000, 54.80500000, 54.91800000, '2026-05-12', '2026-05-12 21:05:39'),
(3, 3.00000000, 60.47400000, 19.53660000, 84.73510000, 61.92960000, 62.05730000, '2026-05-12', '2026-05-12 21:05:39'),
(4, 4.00000000, 68.33560000, 22.07630000, 95.75060000, 69.98050000, 70.12480000, '2026-05-12', '2026-05-12 21:05:39'),
(5, 5.00000000, 77.21920000, 24.94620000, 108.19820000, 79.07800000, 79.24100000, '2026-05-12', '2026-05-12 21:05:39');

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Pazarama kargo desi fiyatlari';

--
-- Tablo döküm verisi `pazarama_kargo_desi_fiyatlari`
--

INSERT INTO `pazarama_kargo_desi_fiyatlari` (`id`, `desi`, `tutar_kdvsiz`, `gecerlilik_tarihi`, `olusturma_tarihi`) VALUES
(1, 1.00000000, 59.32000000, '2026-05-12', '2026-05-12 21:05:39'),
(2, 2.00000000, 67.03160000, '2026-05-12', '2026-05-12 21:05:39'),
(3, 3.00000000, 75.74570000, '2026-05-12', '2026-05-12 21:05:39'),
(4, 4.00000000, 85.59270000, '2026-05-12', '2026-05-12 21:05:39'),
(5, 5.00000000, 96.71970000, '2026-05-12', '2026-05-12 21:05:39');

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
-- Tablo için tablo yapısı `pazaryerleri`
--

DROP TABLE IF EXISTS `pazaryerleri`;
CREATE TABLE IF NOT EXISTS `pazaryerleri` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `kod` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL COMMENT 'trendyol, hepsiburada, flo ...',
  `ad` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL COMMENT 'Trendyol, Hepsiburada, Flo ...',
  `aktif_mi` tinyint(1) NOT NULL DEFAULT '1',
  `para_birimi` varchar(10) COLLATE utf8mb4_turkish_ci NOT NULL DEFAULT 'TRY',
  `ulke` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL DEFAULT 'TR',
  `olusturma_tarihi` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tek_kod` (`kod`),
  KEY `idx_aktif` (`aktif_mi`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Pazaryerleri listesi';

--
-- Tablo döküm verisi `pazaryerleri`
--

INSERT INTO `pazaryerleri` (`id`, `kod`, `ad`, `aktif_mi`, `para_birimi`, `ulke`, `olusturma_tarihi`) VALUES
(1, 'trendyol', 'Trendyol', 1, 'TRY', 'TR', '2026-05-10 21:23:08'),
(2, 'hepsiburada', 'Hepsiburada', 1, 'TRY', 'TR', '2026-05-10 21:23:08'),
(3, 'flo', 'Flo', 1, 'TRY', 'TR', '2026-05-10 21:23:08'),
(4, 'n11', 'N11', 1, 'TRY', 'TR', '2026-05-10 21:23:08'),
(5, 'pazarama', 'Pazarama', 1, 'TRY', 'TR', '2026-05-10 21:23:08'),
(6, 'lcw', 'LCW', 1, 'TRY', 'TR', '2026-05-10 21:23:08'),
(7, 'amazon', 'Amazon', 1, 'TRY', 'TR', '2026-05-10 21:23:08');

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci COMMENT='Trendyol kargo desi fiyatlari';

--
-- Tablo döküm verisi `trendyol_kargo_desi_fiyatlari`
--

INSERT INTO `trendyol_kargo_desi_fiyatlari` (`id`, `desi`, `aras`, `mng`, `ptt`, `sendeo`, `surat`, `tex`, `yurtici`, `borusan`, `ceva`, `horoz`, `gecerlilik_tarihi`, `olusturma_tarihi`) VALUES
(1, 1.00000000, 53.60000000, 63.54200000, 57.32100000, 56.36000000, 58.65400000, 53.41000000, 79.36500000, 410.36000000, 423.65000000, 462.74600000, '2026-05-12', '2026-05-12 21:05:39'),
(2, 2.00000000, 60.56800000, 71.80250000, 64.77270000, 63.68680000, 66.27900000, 60.35330000, 89.68240000, 463.70680000, 478.72450000, 522.90300000, '2026-05-12', '2026-05-12 21:05:39'),
(3, 3.00000000, 68.44180000, 81.13680000, 73.19320000, 71.96610000, 74.89530000, 68.19920000, 101.34120000, 523.98870000, 540.95870000, 590.88040000, '2026-05-12', '2026-05-12 21:05:39'),
(4, 4.00000000, 77.33930000, 91.68460000, 82.70830000, 81.32170000, 84.63170000, 77.06510000, 114.51550000, 592.10720000, 611.28330000, 667.69480000, '2026-05-12', '2026-05-12 21:05:39'),
(5, 5.00000000, 87.39340000, 103.60360000, 93.46040000, 91.89350000, 95.63380000, 87.08360000, 129.40250000, 669.08120000, 690.75010000, 754.49510000, '2026-05-12', '2026-05-12 21:05:39');

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
