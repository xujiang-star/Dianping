-- =============================================
-- 点评网 Supabase 数据库初始化脚本
-- 在 Supabase → SQL Editor 中执行
-- =============================================

-- 1. 创建 Storage 存储桶（用于存储商家图片）
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('shop-images', 'shop-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

-- Storage RLS 策略（公开读写 shop-images 桶）
DROP POLICY IF EXISTS "Public read shop-images" ON storage.objects;
CREATE POLICY "Public read shop-images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'shop-images');

DROP POLICY IF EXISTS "Public upload shop-images" ON storage.objects;
CREATE POLICY "Public upload shop-images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'shop-images');

DROP POLICY IF EXISTS "Public delete shop-images" ON storage.objects;
CREATE POLICY "Public delete shop-images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'shop-images');

-- 2. 商家表
CREATE TABLE IF NOT EXISTS shops (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  rating DECIMAL(2,1) DEFAULT 0,
  review_count INT DEFAULT 0,
  price_range TEXT,
  address TEXT,
  phone TEXT,
  hours TEXT,
  image TEXT,
  description TEXT,
  tags TEXT[] DEFAULT '{}'
);

-- 3. 评价表
CREATE TABLE IF NOT EXISTS reviews (
  id BIGSERIAL PRIMARY KEY,
  shop_id BIGINT REFERENCES shops(id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  content TEXT NOT NULL,
  date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. 启用行级安全 (RLS)
ALTER TABLE shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- 5. RLS 策略
DROP POLICY IF EXISTS "Public can read shops" ON shops;
CREATE POLICY "Public can read shops" ON shops FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public can read reviews" ON reviews;
CREATE POLICY "Public can read reviews" ON reviews FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public can insert reviews" ON reviews;
CREATE POLICY "Public can insert reviews" ON reviews FOR INSERT WITH CHECK (true);

-- 6. 插入示例商家数据（图片指向 Supabase Storage）
INSERT INTO shops (name, category, rating, review_count, price_range, address, phone, hours, image, description, tags)
SELECT '鼎泰丰 (新天地店)', 'food', 4.8, 12580, '¥150-250', '上海市黄浦区新天地北里15号', '021-6385-7504', '11:00 - 22:00',
  'shop-1.webp',
  '鼎泰丰是一家享誉全球的中式点心餐厅，以精致的小笼包闻名。坚持"每个小笼包18个褶"的手工制作标准，选用最新鲜的食材，为您呈现地道的中华美食文化。',
  ARRAY['小笼包', '蟹黄汤包', '精致点心']
WHERE NOT EXISTS (SELECT 1 FROM shops WHERE name = '鼎泰丰 (新天地店)');

INSERT INTO shops (name, category, rating, review_count, price_range, address, phone, hours, image, description, tags)
SELECT '万达影城 (五角场店)', 'movie', 4.6, 8932, '¥40-80', '上海市杨浦区邯郸路1000号万达广场5F', '021-6566-6666', '10:00 - 次日02:00',
  'shop-2.webp',
  '万达影城配备IMAX巨幕厅、杜比全景声影厅，提供极致视听体验。',
  ARRAY['IMAX', '杜比全景声', 'VIP厅']
WHERE NOT EXISTS (SELECT 1 FROM shops WHERE name = '万达影城 (五角场店)');

INSERT INTO shops (name, category, rating, review_count, price_range, address, phone, hours, image, description, tags)
SELECT '外滩W酒店', 'hotel', 4.9, 5623, '¥2000-5000', '上海市虹口区中山东一路66号', '021-2286-6666', '24小时营业',
  'shop-3.webp',
  '外滩W酒店坐拥浦江两岸壮丽夜景，将现代潮流与东方魅力完美融合。',
  ARRAY['江景房', '米其林', '酒吧']
WHERE NOT EXISTS (SELECT 1 FROM shops WHERE name = '外滩W酒店');

INSERT INTO shops (name, category, rating, review_count, price_range, address, phone, hours, image, description, tags)
SELECT '太古汇购物中心', 'shopping', 4.7, 15234, '¥100-5000', '上海市静安区南京西路789号', '021-6288-7777', '10:00 - 22:00',
  'shop-4.webp',
  '太古汇汇集全球顶级品牌，包括LV、Gucci、Prada等。',
  ARRAY['奢侈品', '潮流品牌', '高端购物']
WHERE NOT EXISTS (SELECT 1 FROM shops WHERE name = '太古汇购物中心');

INSERT INTO shops (name, category, rating, review_count, price_range, address, phone, hours, image, description, tags)
SELECT '沙宣美发沙龙 (恒隆店)', 'hair', 4.5, 3421, '¥300-800', '上海市静安区南京西路1266号恒隆广场B1', '021-6288-0099', '10:30 - 21:30',
  'shop-5.webp',
  '沙宣美发沙龙拥有一支由国际资深发型师组成的团队。',
  ARRAY['资深发型师', '剪发', '染发']
WHERE NOT EXISTS (SELECT 1 FROM shops WHERE name = '沙宣美发沙龙 (恒隆店)');

INSERT INTO shops (name, category, rating, review_count, price_range, address, phone, hours, image, description, tags)
SELECT '徐家汇体育公园', 'sport', 4.4, 6789, '¥20-100', '上海市徐汇区肇嘉浜路1111号', '021-6487-0000', '06:00 - 22:00',
  'shop-6.webp',
  '徐家汇体育公园设施完善，包含标准足球场、篮球场、羽毛球场和环形跑道。',
  ARRAY['足球场', '篮球场', '跑步']
WHERE NOT EXISTS (SELECT 1 FROM shops WHERE name = '徐家汇体育公园');

INSERT INTO shops (name, category, rating, review_count, price_range, address, phone, hours, image, description, tags)
SELECT '上海图书馆 (东馆)', 'study', 4.8, 4532, '免费', '上海市浦东新区合欢路300号', '021-6445-3309', '09:00 - 20:30',
  'shop-7.webp',
  '上海图书馆东馆藏书丰富，设有多个主题阅览室、儿童阅览区和数字资源中心。',
  ARRAY['自习室', '儿童阅览', '免费']
WHERE NOT EXISTS (SELECT 1 FROM shops WHERE name = '上海图书馆 (东馆)');

INSERT INTO shops (name, category, rating, review_count, price_range, address, phone, hours, image, description, tags)
SELECT '小杨生煎 (南京西路店)', 'food', 4.6, 9876, '¥30-60', '上海市静安区南京西路735号', '021-6215-2377', '06:00 - 22:00',
  'shop-8.webp',
  '小杨生煎是上海著名的特色小吃，以"皮薄、馅多、汤鲜"著称。',
  ARRAY['生煎包', '上海小吃', '性价比']
WHERE NOT EXISTS (SELECT 1 FROM shops WHERE name = '小杨生煎 (南京西路店)');

-- 7. 插入示例评价
INSERT INTO reviews (shop_id, username, rating, content, date)
SELECT 1, '美食爱好者', 5, '鼎泰丰的小笼包真的是一绝！皮薄汁多，肉馅鲜美。环境也非常优雅，适合商务宴请或家庭聚餐。强烈推荐蟹黄汤包！', '2026-08-15'
WHERE NOT EXISTS (SELECT 1 FROM reviews WHERE shop_id = 1 AND username = '美食爱好者');

INSERT INTO reviews (shop_id, username, rating, content, date)
SELECT 1, '上海老饕', 4, '作为上海老字号，鼎泰丰的品质一直很稳定。就是价格偏高一些，但一分钱一分货，值得体验。', '2026-08-10'
WHERE NOT EXISTS (SELECT 1 FROM reviews WHERE shop_id = 1 AND username = '上海老饕');

INSERT INTO reviews (shop_id, username, rating, content, date)
SELECT 2, '影迷小王', 5, 'IMAX厅效果非常棒，屏幕大，音效震撼。座位也很舒服，就是人有点多，建议提前订票。', '2026-08-12'
WHERE NOT EXISTS (SELECT 1 FROM reviews WHERE shop_id = 2 AND username = '影迷小王');

INSERT INTO reviews (shop_id, username, rating, content, date)
SELECT 3, '旅行达人', 5, '外滩W酒店的江景房视野无敌！服务一流，早餐丰富。强烈推荐入住体验！', '2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM reviews WHERE shop_id = 3 AND username = '旅行达人');

INSERT INTO reviews (shop_id, username, rating, content, date)
SELECT 7, '考研党', 5, '图书馆环境超好，安静舒适，座位充足。非常适合备考自习！', '2026-08-16'
WHERE NOT EXISTS (SELECT 1 FROM reviews WHERE shop_id = 7 AND username = '考研党');
