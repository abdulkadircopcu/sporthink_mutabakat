-- ============================================================
-- E-Ticaret Dijital Mutabakat ve Karlılık Analizi Platformu
-- Veritabanı Şeması v1.0
-- ============================================================

CREATE DATABASE IF NOT EXISTS eticaret_mutabakat
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_turkish_ci;

USE eticaret_mutabakat;


-- ------------------------------------------------------------
-- 1. ORDERS — Ana sipariş tablosu
--    Her pazaryerinden gelen her sipariş buraya girer.
-- ------------------------------------------------------------
CREATE TABLE orders (
    id                      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id                VARCHAR(100)    NOT NULL COMMENT 'Kendi sistemimizden sipariş no',
    marketplace_order_id    VARCHAR(100)    NOT NULL COMMENT 'Pazaryerinin sipariş no',
    marketplace             ENUM('Trendyol','Hepsiburada','Flo','N11','Pazarama','LCW','Amazon') NOT NULL,
    status                  ENUM('teslim_edildi','iade','iptal','beklemede') NOT NULL DEFAULT 'beklemede',
    barcode                 VARCHAR(100)    NOT NULL COMMENT 'Ürün barkodu / SKU',
    quantity                SMALLINT        NOT NULL DEFAULT 1,
    unit_price              DECIMAL(12,2)   NOT NULL COMMENT 'Pazaryeri satış fiyatı (KDV dahil)',
    kdv_rate                DECIMAL(5,2)    NOT NULL DEFAULT 20.00 COMMENT 'KDV oranı %',
    total_amount            DECIMAL(12,2)   NOT NULL COMMENT 'Sipariş toplam tutarı',
    order_created_at        DATETIME        NOT NULL COMMENT 'Siparişin oluşma zamanı',
    cargo_sent_at           DATETIME        NULL     COMMENT 'Kargo gönderim tarihi',
    source_store            VARCHAR(100)    NULL     COMMENT 'Kaynak mağaza / kanal',
    created_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_marketplace_order (marketplace, marketplace_order_id),
    INDEX idx_marketplace (marketplace),
    INDEX idx_status (status),
    INDEX idx_barcode (barcode),
    INDEX idx_order_created (order_created_at)
) ENGINE=InnoDB COMMENT='Ana sipariş tablosu';


-- ------------------------------------------------------------
-- 2. ORDER_ITEMS — Sipariş satır detayı
--    Bir siparişte birden fazla ürün olabilir.
--    Kesintiler ürün bazına burada dağıtılır.
-- ------------------------------------------------------------
CREATE TABLE order_items (
    id                          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id                    INT UNSIGNED    NOT NULL,
    barcode                     VARCHAR(100)    NOT NULL,
    product_name                VARCHAR(255)    NULL,
    quantity                    SMALLINT        NOT NULL DEFAULT 1,
    unit_price                  DECIMAL(12,2)   NOT NULL COMMENT 'Pazaryeri birim fiyatı',
    product_cost                DECIMAL(12,2)   NOT NULL COMMENT 'Ürün maliyeti (ERP''den)',
    sale_quantity               SMALLINT        NOT NULL DEFAULT 0,
    sale_amount                 DECIMAL(12,2)   NOT NULL DEFAULT 0.00,
    return_quantity             SMALLINT        NOT NULL DEFAULT 0,
    return_amount               DECIMAL(12,2)   NOT NULL DEFAULT 0.00,

    -- Desi (hacimsel ağırlık)
    estimated_desi              DECIMAL(8,3)    NULL,
    billed_desi                 DECIMAL(8,3)    NULL,
    calculated_desi_amount      DECIMAL(12,2)   NULL,

    -- Hesaplanan kesintiler (dağıtılmış)
    calc_sale_commission        DECIMAL(12,2)   NULL COMMENT 'Hesaplanan satış komisyonu',
    calc_return_commission      DECIMAL(12,2)   NULL COMMENT 'Hesaplanan iade komisyonu',
    calc_cargo_amount           DECIMAL(12,2)   NULL COMMENT 'Hesaplanan kargo tutarı',

    -- Net hesaplamalar
    net_revenue                 DECIMAL(12,2)   NULL COMMENT 'Net gelir',
    net_profit                  DECIMAL(12,2)   NULL COMMENT 'Net kâr',
    profit_margin               DECIMAL(8,4)    NULL COMMENT 'Kâr marjı (0-1 arası)',

    created_at                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_items_order (order_id),
    INDEX idx_items_barcode (barcode)
) ENGINE=InnoDB COMMENT='Sipariş satır detayı ve ürün bazlı kârlılık';


-- ------------------------------------------------------------
-- 3. MARKETPLACE_INVOICES — Pazaryeri fatura kalemleri
--    Komisyon, kargo, ceza, iade gibi tüm fatura satırları.
-- ------------------------------------------------------------
CREATE TABLE marketplace_invoices (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id            INT UNSIGNED    NULL     COMMENT 'Eşleşen sipariş (nullable: toplu ödemeler için)',
    marketplace         ENUM('Trendyol','Hepsiburada','Flo','N11','Pazarama','LCW','Amazon') NOT NULL,
    invoice_no          VARCHAR(100)    NULL,
    invoice_date        DATE            NOT NULL,
    item_type           VARCHAR(100)    NOT NULL COMMENT 'Kalem tipi (komisyon, kargo, ceza vb.)',
    amount              DECIMAL(12,2)   NOT NULL COMMENT 'Pozitif = gelir, negatif = gider',
    direction           ENUM('gelir','gider') NOT NULL COMMENT 'Gelir mi gider mi',
    description         VARCHAR(500)    NULL,
    raw_data            JSON            NULL     COMMENT 'Ham CSV/Excel satırı (yedek)',
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_inv_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL,
    INDEX idx_inv_marketplace (marketplace),
    INDEX idx_inv_date (invoice_date),
    INDEX idx_inv_type (item_type),
    INDEX idx_inv_order (order_id)
) ENGINE=InnoDB COMMENT='Pazaryeri fatura kalemleri';


-- ------------------------------------------------------------
-- 4. ORDER_FINANCIALS — Mutabakat ve ödeme takibi
--    Beklenen ödeme ile gerçekleşen ödeme karşılaştırılır.
-- ------------------------------------------------------------
CREATE TABLE order_financials (
    id                      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id                INT UNSIGNED    NOT NULL,
    marketplace             ENUM('Trendyol','Hepsiburada','Flo','N11','Pazarama','LCW','Amazon') NOT NULL,

    -- Beklenen ödemeler (hesaplanan)
    expected_payment        DECIMAL(12,2)   NULL COMMENT 'Beklenen net ödeme',
    expected_commission     DECIMAL(12,2)   NULL,
    expected_cargo          DECIMAL(12,2)   NULL,
    expected_stopaj         DECIMAL(12,2)   NULL,

    -- Gerçekleşen ödemeler (faturadan gelen)
    actual_payment          DECIMAL(12,2)   NULL COMMENT 'Gerçekleşen ödeme',
    billed_commission       DECIMAL(12,2)   NULL,
    billed_cargo_sale       DECIMAL(12,2)   NULL,
    billed_cargo_return     DECIMAL(12,2)   NULL,
    billed_stopaj           DECIMAL(12,2)   NULL,

    -- Fark analizi
    payment_diff            DECIMAL(12,2)   NULL COMMENT 'Beklenen - gerçekleşen fark',
    commission_diff         DECIMAL(12,2)   NULL,
    cargo_diff              DECIMAL(12,2)   NULL,

    -- Mutabakat durumu
    reconciliation_status   ENUM('eslesdi','fark_var','manuel_inceleme','beklemede') NOT NULL DEFAULT 'beklemede',
    confidence_score        DECIMAL(5,2)    NULL COMMENT 'Eşleşme güven skoru 0-100',
    notes                   TEXT            NULL,

    reconciled_at           DATETIME        NULL,
    created_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_fin_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    UNIQUE KEY uq_fin_order (order_id),
    INDEX idx_fin_status (reconciliation_status),
    INDEX idx_fin_marketplace (marketplace)
) ENGINE=InnoDB COMMENT='Mutabakat ve ödeme takibi';


-- ------------------------------------------------------------
-- 5. PROFITABILITY_SUMMARY — Son tablo / Dashboard kaynağı
--    Tüm veriler burada birleşir. ETL her çalıştığında güncellenir.
-- ------------------------------------------------------------
CREATE TABLE profitability_summary (
    id                              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id                        INT UNSIGNED    NOT NULL,
    marketplace_order_id            VARCHAR(100)    NOT NULL,
    barcode                         VARCHAR(100)    NOT NULL,
    marketplace                     ENUM('Trendyol','Hepsiburada','Flo','N11','Pazarama','LCW','Amazon') NOT NULL,
    order_status                    VARCHAR(50)     NOT NULL,
    order_created_at                DATETIME        NOT NULL,

    -- Satış
    sale_quantity                   SMALLINT        NULL,
    sale_amount                     DECIMAL(12,2)   NULL,
    return_quantity                 SMALLINT        NULL,
    return_amount                   DECIMAL(12,2)   NULL,

    -- Maliyetler
    product_cost                    DECIMAL(12,2)   NULL,
    cargo_cost                      DECIMAL(12,2)   NULL,

    -- Pazaryeri kesintileri (gider = negatif, gelir = pozitif)
    commission_sale                 DECIMAL(12,2)   NULL,
    commission_return               DECIMAL(12,2)   NULL,
    cargo_sale                      DECIMAL(12,2)   NULL,
    cargo_return                    DECIMAL(12,2)   NULL,
    stopaj                          DECIMAL(12,2)   NULL,
    stopaj_return                   DECIMAL(12,2)   NULL,
    penalty_supply                  DECIMAL(12,2)   NULL COMMENT 'Tedarik edememe',
    penalty_delay                   DECIMAL(12,2)   NULL COMMENT 'Gecikme cezası',
    penalty_wrong_item              DECIMAL(12,2)   NULL COMMENT 'Yanlış ürün',
    penalty_defective               DECIMAL(12,2)   NULL COMMENT 'Kusurlu ürün',
    penalty_missing                 DECIMAL(12,2)   NULL COMMENT 'Eksik ürün',
    discount_coupon                 DECIMAL(12,2)   NULL,
    discount_campaign               DECIMAL(12,2)   NULL,
    marketing_fee                   DECIMAL(12,2)   NULL,
    platform_fee                    DECIMAL(12,2)   NULL,
    ad_spend                        DECIMAL(12,2)   NULL,
    other_deductions                DECIMAL(12,2)   NULL,

    -- Net hesaplamalar
    net_revenue                     DECIMAL(12,2)   NULL COMMENT 'Net gelir',
    net_profit                      DECIMAL(12,2)   NULL COMMENT 'Net kâr',
    profit_margin                   DECIMAL(8,4)    NULL COMMENT 'Kâr marjı',
    is_loss                         TINYINT(1)      NOT NULL DEFAULT 0 COMMENT '1 = zarar eden sipariş',

    -- Mutabakat
    reconciliation_status           ENUM('eslesdi','fark_var','manuel_inceleme','beklemede') NULL,
    payment_diff                    DECIMAL(12,2)   NULL,

    -- ETL meta
    last_calculated_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_ps_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    UNIQUE KEY uq_ps_order (order_id),
    INDEX idx_ps_marketplace (marketplace),
    INDEX idx_ps_status (order_status),
    INDEX idx_ps_loss (is_loss),
    INDEX idx_ps_created (order_created_at),
    INDEX idx_ps_barcode (barcode)
) ENGINE=InnoDB COMMENT='Son tablo — dashboard ve raporlama kaynağı';
