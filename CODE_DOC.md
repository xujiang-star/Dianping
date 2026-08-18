# 点评网完整代码文档

> 本项目基于 Next.js 16 + TypeScript + Tailwind CSS v4 + Supabase
> 共 20 个文件，全部逐行解释

---

## 📁 项目结构总览

```
dianping-clone/
├── src/
│   ├── app/                          # 页面目录
│   │   ├── layout.tsx                # 根布局（所有页面共用外壳）
│   │   ├── page.tsx                  # 首页
│   │   ├── globals.css               # 全局样式
│   │   ├── shop/[id]/page.tsx        # 商家详情页
│   │   └── api/                      # 后端接口
│   │       └── shops/
│   │           ├── route.ts          # 商家列表 API
│   │           └── [id]/
│   │               ├── route.ts      # 单个商家 API
│   │               └── reviews/
│   │                   └── route.ts  # 评价 API
│   ├── components/                   # UI 组件
│   │   ├── Header.tsx                # 顶部导航栏
│   │   ├── ShopCard.tsx              # 商家卡片
│   │   ├── CategoryFilter.tsx        # 分类筛选按钮
│   │   ├── StarRating.tsx            # 星级评分
│   │   ├── ReviewForm.tsx            # 评价表单
│   │   ├── ReviewList.tsx            # 评价列表
│   │   ├── LoadingSpinner.tsx        # 加载动画
│   │   └── Toast.tsx                 # 提示气泡
│   ├── lib/                          # 工具库
│   │   ├── supabase.ts               # 数据库连接
│   │   └── storage.ts                # 图片 URL 处理
│   └── types/index.ts                # TypeScript 类型定义
├── supabase_init.sql                 # 数据库初始化脚本
└── .env.local                        # 环境变量（密码）
```

---

## 🧱 核心概念速查

| 名词 | 解释 | 类比 |
|------|------|------|
| **组件** | 可复用的 UI 块 | 乐高积木 |
| **Hook** | React 特殊函数，`use` 开头 | 工具箱 |
| **useState** | 响应式变量 | 盒子（装数据） |
| **useEffect** | 副作用（加载时执行） | 开机自启 |
| **useMemo** | 缓存计算结果 | 记事本 |
| **API Route** | Next.js 后端接口 | 传菜口 |
| **fetch** | 发送 HTTP 请求 | 打电话 |
| **Tailwind** | CSS 工具类 | 现成贴纸 |
| **JSX** | JS + HTML 混合语法 | 带逻辑的 HTML |
| **TS** | 带类型检查的 JS | 带安全带的车 |
| **Suspense** | 等待子组件时显示 loading | 门帘 |

---

# 📖 文件 1: src/app/layout.tsx

**作用**：所有页面共享的最外层 HTML 框架

```tsx
// 第1行：从 Next.js 导入元数据类型（用于网页标题/描述）
import type { Metadata } from "next";

// 第2行：从 Google Fonts 导入 2 种字体（正文+代码）
import { Geist, Geist_Mono } from "next/font/google";

// 第3行：导入全局样式
import "./globals.css";

// 第5-8行：配置无衬线字体（变量名 --font-geist-sans）
const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

// 第10-13行：配置等宽字体（代码用）
const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

// 第15-18行：定义网页元数据（浏览器标签页显示的标题）
export const metadata: Metadata = {
  title: "点评网 - 发现身边的精彩",
  description: "点评网 - 真实评价，精选推荐，吃喝玩乐全覆盖",
};

// 第20行：根布局组件，{ children } 是子页面内容
// 比喻：这是房子的框架，children 是里面的家具
export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html
      lang="zh-CN"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
      // lang="zh-CN"：中文语言
      // className：应用字体变量 + 全高 + 抗锯齿
    >
      <body className="min-h-full flex flex-col">
        {/* min-h-full：至少全屏高；flex flex-col：垂直弹性布局 */}
        {children}
      </body>
    </html>
  );
}
```

---

# 📖 文件 2: src/lib/supabase.ts

**作用**：创建与 Supabase 数据库的连接（"电话线"）

```ts
// 第1行：从 Supabase 官方 JS 库导入创建客户端的函数
import { createClient } from '@supabase/supabase-js';

// 第3行：读取环境变量中的 Supabase 项目 URL
// NEXT_PUBLIC_ 前缀 = 前端也能访问
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;

// 第4行：读取环境变量中的匿名密钥
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

// 第6-10行：检查配置是否存在，缺失则抛出错误
// 这样开发者一眼能看出问题所在
if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    '缺少 Supabase 环境变量。请复制 .env.local.example 为 .env.local 并填入你的 Supabase 项目凭据。'
  );
}

// 第12行：创建并导出数据库客户端
// 其他文件通过 import { supabase } from '@/lib/supabase' 使用
export const supabase = createClient(supabaseUrl, supabaseAnonKey);
```

---

# 📖 文件 3: src/types/index.ts

**作用**：定义 TypeScript 类型（"数据的图纸"）

```ts
// 第1-14行：Shop 接口 — 对应数据库 shops 表
export interface Shop {
  id: number;          // 主键，自增
  name: string;        // 商家名称
  category: string;    // 分类（food/movie/hotel 等）
  rating: number;      // 评分（0-5，保留1位小数）
  review_count: number;// 评价数
  price_range: string;  // 价格区间（如 "¥150-250"）
  address: string;     // 地址
  phone: string;       // 电话
  hours: string;       // 营业时间
  image: string;       // 图片文件名（存在 Supabase Storage）
  description: string; // 商家描述
  tags: string[];      // 标签数组（如 ["小笼包", "蟹黄汤包"]）
}

// 第16-24行：Review 接口 — 对应数据库 reviews 表
export interface Review {
  id: number;          // 主键
  shop_id: number;     // 外键，关联 shops.id
  username: string;    // 评价用户名
  rating: number;      // 评分（1-5 整数）
  content: string;     // 评价内容
  date: string;        // 评价日期
  created_at?: string; // 创建时间（可选，自动生成）
}

// 第26-30行：Category 接口 — 分类定义
export interface Category {
  id: string;    // 分类标识
  name: string;  // 分类中文名
  icon: string;  // emoji 图标
}

// 第32-41行：分类数据（首页分类按钮用）
export const categories: Category[] = [
  { id: 'all', name: '全部', icon: '🍽️' },
  { id: 'food', name: '美食', icon: '🥢' },
  { id: 'movie', name: '电影', icon: '🎬' },
  { id: 'hotel', name: '酒店', icon: '🏨' },
  { id: 'shopping', name: '购物', icon: '🛍️' },
  { id: 'hair', name: '丽人', icon: '💇' },
  { id: 'sport', name: '运动', icon: '⚽' },
  { id: 'study', name: '学习', icon: '📚' },
];
```

---

# 📖 文件 4: src/app/globals.css

**作用**：全局样式（Tailwind CSS 入口）

```css
/* 第1行：导入 Tailwind CSS v4（新版语法） */
@import "tailwindcss";

/* 第3-6行：定义 CSS 变量（可被 Tailwind 引用） */
:root {
  --background: #f9fafb;   /* 背景色：浅灰 */
  --foreground: #111827;   /* 前景色：深灰黑 */
}

/* 第8-13行：Tailwind v4 主题配置（内联模式） */
@theme inline {
  --color-background: var(--background);  /* 映射到 Tailwind */
  --color-foreground: var(--foreground);
  --font-sans: var(--font-geist-sans);    /* 字体变量 */
  --font-mono: var(--font-geist-mono);
}

/* 第15-19行：body 基础样式 */
body {
  background: var(--background);
  color: var(--foreground);
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI',
    'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif;
  /* 字体栈：优先系统字体，保证中文显示 */
}

/* 第21-24行：隐藏滚动条（Firefox/IE） */
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}

/* 第26-28行：隐藏滚动条（Chrome/Safari） */
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
```

---

# 📖 文件 5: src/lib/storage.ts

**作用**：处理图片 URL（把文件名转成完整的 Supabase Storage 地址）

```ts
// 第1行：导入已创建的 Supabase 客户端
import { supabase } from './supabase';

// 第3行：常量 — Storage 存储桶名称
const BUCKET_NAME = 'shop-images';

// 第5-13行：获取图片完整 URL 的函数
export function getImageUrl(path: string | null | undefined): string {
  // 第6行：空值保护
  if (!path) return '';

  // 第8-10行：如果已经是完整 URL，直接返回
  // （示例数据可能有预置的 http 开头的 URL）
  if (path.startsWith('http')) {
    return path;
  }

  // 第12-13行：从 Supabase Storage 获取公开 URL
  // path 是文件名（如 "shop-1.webp"），拼接成完整 HTTPS URL
  const { data } = supabase.storage.from(BUCKET_NAME).getPublicUrl(path);
  return data?.publicUrl || '';  // 返回公开地址，失败则返回空串
}
```

---

# 📖 文件 6: src/components/Header.tsx

**作用**：顶部导航栏（Logo + 分类导航 + 登录/注册）

```tsx
// ========== 导入部分 ==========

// 第1行：'use client' 声明为客户端组件（可用 React Hooks）
'use client';

// 第3行：导入 React Hooks
import { Suspense, useState, useEffect } from 'react';
// Suspense：等待子组件时显示 fallback
// useState：状态管理
// useEffect：副作用

// 第4行：导入 Next.js 导航工具
import { useRouter, useSearchParams } from 'next/navigation';
// useRouter：路由器（跳转页面）
// useSearchParams：读取 URL 参数（如 ?category=food）

// 第5行：导入 Next.js Link（预加载+客户端导航）
import Link from 'next/link';

// ========== 类型定义 ==========

// 第7-9行：Header 组件的 props 接口
interface HeaderProps {
  onLogout?: () => void;  // 可选的退出登录回调
}

// ========== 导航数据 ==========

// 第11-20行：导航项配置（8个分类 + 首页）
const navItems = [
  { label: '首页', category: 'all' },
  { label: '美食', category: 'food' },
  { label: '电影', category: 'movie' },
  { label: '酒店', category: 'hotel' },
  { label: '购物', category: 'shopping' },
  { label: '丽人', category: 'hair' },
  { label: '运动', category: 'sport' },
  { label: '学习', category: 'study' },
];

// ========== 主组件（外部包裹 Suspense） ==========

// 第22-28行：Header 主组件
// 因为内部使用 useSearchParams，必须用 Suspense 包裹
export default function Header(props: HeaderProps) {
  return (
    <Suspense fallback={<div className="h-16 bg-white border-b border-gray-100" />}>
      {/* fallback：加载中时显示的占位条 */}
      <HeaderContent {...props} />
    </Suspense>
  );
}

// ========== 实际内容组件 ==========

// 第30行：HeaderContent 组件
function HeaderContent({ onLogout }: HeaderProps) {
  // 第31行：获取路由器
  const router = useRouter();
  
  // 第32行：读取 URL 参数中的 category 值
  // 直接从 URL 读取，确保与首页状态同步
  const searchParams = useSearchParams();
  
  // 第33-35行：状态定义
  const [showLoginModal, setShowLoginModal] = useState(false);     // 登录弹窗
  const [showRegisterModal, setShowRegisterModal] = useState(false); // 注册弹窗
  const [currentUser, setCurrentUser] = useState<string | null>(null); // 当前用户

  // 第37行：从 URL 获取当前激活的分类，默认 'all'
  const activeCategory = searchParams.get('category') || 'all';

  // 第39-42行：组件挂载时，从 localStorage 恢复登录状态
  useEffect(() => {
    const user = localStorage.getItem('dianping_user');
    if (user) setCurrentUser(user);
  }, []);  // [] = 只执行 1 次（挂载时）

  // 第44-50行：点击导航项的处理函数
  const handleNav = (category: string) => {
    if (category === 'all') {
      router.push('/', { scroll: false });
      // scroll: false = 不滚动到顶部
    } else {
      router.push(`/?category=${category}`, { scroll: false });
      // 只改 URL 参数，不刷新页面
    }
  };

  // 第52-56行：登录成功回调
  const handleLoginSuccess = (username: string) => {
    setCurrentUser(username);       // 更新当前用户
    setShowLoginModal(false);       // 关闭登录弹窗
    setShowRegisterModal(false);    // 关闭注册弹窗
  };

  // 第58-62行：退出登录
  const handleLogout = () => {
    localStorage.removeItem('dianping_user');  // 清除本地存储
    setCurrentUser(null);                       // 清空状态
    onLogout?.();                               // 调用外部回调（可选）
  };

  // ========== 渲染部分 ==========

  return (
    <>
      {/* 第66行：<header> 语义化标签
          sticky top-0：固定在顶部
          z-50：层级 50（较高）
          bg-white/95：白色 95% 透明
          backdrop-blur：背景模糊
          border-b：底部边框
          shadow-sm：小阴影
      */}
      <header className="sticky top-0 z-50 bg-white/95 backdrop-blur border-b border-gray-100 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between">
          {/* 第68-73行：Logo 区域 */}
          <Link href="/" className="flex items-center gap-2">
            <div className="w-9 h-9 rounded-lg bg-orange-500 flex items-center justify-center text-white font-bold text-lg">
              点
            </div>
            <span className="text-xl font-bold text-orange-500">点评网</span>
          </Link>

          {/* 第74-92行：导航菜单 */}
          <nav className="hidden md:flex items-center gap-5 text-sm text-gray-600">
            {/* hidden md:flex：手机隐藏，平板以上显示 */}
            {navItems.map((item) => {
              const isActive = item.category === activeCategory;
              return (
                <button
                  key={item.label}
                  onClick={() => handleNav(item.category)}
                  className={`relative hover:text-orange-500 transition-colors py-2 ${
                    isActive ? 'text-orange-500 font-medium' : ''
                  }`}
                >
                  {item.label}
                  {/* 激活时显示橙色下划线 */}
                  {isActive && (
                    <span className="absolute -bottom-0.5 left-0 right-0 h-0.5 bg-orange-500 rounded-full" />
                  )}
                </button>
              );
            })}
          </nav>

          {/* 第93-122行：右侧用户区 */}
          <div className="flex items-center gap-3">
            {currentUser ? (
              // 已登录：显示用户名 + 退出按钮
              <>
                <span className="text-sm text-gray-600">
                  你好，<span className="text-orange-500 font-medium">{currentUser}</span>
                </span>
                <button onClick={handleLogout} className="text-sm text-gray-500 hover:text-orange-500">
                  退出
                </button>
              </>
            ) : (
              // 未登录：显示登录 + 注册按钮
              <>
                <button onClick={() => setShowLoginModal(true)} className="text-sm text-gray-600 hover:text-orange-500">
                  登录
                </button>
                <button onClick={() => setShowRegisterModal(true)} className="text-sm px-4 py-2 bg-orange-500 text-white rounded-full hover:bg-orange-600">
                  注册
                </button>
              </>
            )}
          </div>
        </div>
      </header>

      {/* 第126-136行：登录弹窗 */}
      {showLoginModal && (
        <AuthModal
          mode="login"
          onClose={() => setShowLoginModal(false)}
          onSuccess={handleLoginSuccess}
          switchMode={() => { setShowLoginModal(false); setShowRegisterModal(true); }}
        />
      )}

      {/* 第137-147行：注册弹窗 */}
      {showRegisterModal && (
        <AuthModal
          mode="register"
          onClose={() => setShowRegisterModal(false)}
          onSuccess={handleLoginSuccess}
          switchMode={() => { setShowRegisterModal(false); setShowLoginModal(true); }}
        />
      )}
    </>
  );
}

// ========== 登录/注册弹窗组件 ==========

// 第152-162行：AuthModal 组件的 props 类型
function AuthModal({
  mode,        // 'login' 或 'register'
  onClose,     // 关闭弹窗
  onSuccess,   // 成功回调
  switchMode,  // 切换登录/注册
}: {
  mode: 'login' | 'register';
  onClose: () => void;
  onSuccess: (username: string) => void;
  switchMode: () => void;
}) {
  const isLogin = mode === 'login';

  // 第165-198行：表单提交处理
  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();  // 阻止默认提交行为
    const formData = new FormData(e.currentTarget);
    const username = (formData.get('username') as string)?.trim();
    const password = (formData.get('password') as string)?.trim();

    if (!username || !password) return;  // 空值校验

    if (isLogin) {
      // === 登录逻辑 ===
      // 从 localStorage 读取所有注册用户
      const users = JSON.parse(localStorage.getItem('dianping_users') || '[]');
      // 查找匹配的用户名+密码
      const user = users.find(
        (u: { username: string; password: string }) =>
          u.username === username && u.password === password
      );
      if (user) {
        localStorage.setItem('dianping_user', username);
        onSuccess(username);
      } else {
        alert('用户名或密码错误，请先注册');
      }
    } else {
      // === 注册逻辑 ===
      const users = JSON.parse(localStorage.getItem('dianping_users') || '[]');
      // 检查用户名是否重复
      if (users.find((u: { username: string }) => u.username === username)) {
        alert('该用户名已被注册');
        return;
      }
      // 保存新用户
      users.push({ username, password });
      localStorage.setItem('dianping_users', JSON.stringify(users));
      localStorage.setItem('dianping_user', username);
      onSuccess(username);
    }
  };

  // 第200-280行：弹窗 UI
  return (
    <div className="fixed inset-0 z-[100] bg-black/50 flex items-center justify-center p-4"
         onClick={onClose}>
      {/* fixed inset-0：全屏遮罩
          bg-black/50：黑色 50% 透明
          z-[100]：最高层级
          点击外部关闭 */}
      <div className="bg-white rounded-2xl p-6 w-full max-w-md shadow-xl"
           onClick={(e) => e.stopPropagation()}>
        {/* 阻止冒泡：点击内部不关闭 */}
        
        {/* 标题栏 */}
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-bold text-gray-900">
            {isLogin ? '登录点评网' : '注册点评网账号'}
          </h2>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600 text-2xl leading-none">
            ×
          </button>
        </div>

        {/* 表单 */}
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* 用户名 */}
          <div>
            <label className="block text-sm text-gray-600 mb-1">用户名</label>
            <input name="username" type="text" required placeholder="请输入用户名"
              className="w-full px-4 py-2.5 rounded-lg border border-gray-200 focus:border-orange-500 focus:outline-none focus:ring-1 focus:ring-orange-500 text-sm" />
          </div>
          {/* 密码 */}
          <div>
            <label className="block text-sm text-gray-600 mb-1">密码</label>
            <input name="password" type="password" required
              placeholder={isLogin ? '请输入密码' : '至少 6 位'}
              minLength={isLogin ? 1 : 6}
              className="w-full px-4 py-2.5 rounded-lg border border-gray-200 focus:border-orange-500 focus:outline-none focus:ring-1 focus:ring-orange-500 text-sm" />
          </div>
          {/* 提交按钮 */}
          <button type="submit"
            className="w-full py-3 bg-orange-500 text-white rounded-lg font-medium hover:bg-orange-600 transition-colors">
            {isLogin ? '登录' : '注册'}
          </button>
        </form>

        {/* 切换链接 */}
        <div className="mt-4 text-center text-sm text-gray-500">
          {isLogin ? (
            <>还没有账号？ <button onClick={switchMode} className="text-orange-500 hover:underline">立即注册</button></>
          ) : (
            <>已有账号？ <button onClick={switchMode} className="text-orange-500 hover:underline">立即登录</button></>
          )}
        </div>

        {/* 提示 */}
        <p className="mt-4 text-xs text-gray-400 text-center">
          * 演示版：账号数据保存在浏览器本地
        </p>
      </div>
    </div>
  );
}
```

---

# 📖 文件 7: src/components/ShopCard.tsx

**作用**：单个商家卡片（首页列表用）

```tsx
// 第1行：导入 Next.js Link（点击卡片跳转到详情页）
import Link from 'next/link';

// 第2行：导入星级评分组件
import StarRating from './StarRating';

// 第3行：导入图片 URL 处理函数
import { getImageUrl } from '@/lib/storage';

// 第4行：导入 Shop 类型
import type { Shop } from '@/types';

// 第6行：ShopCard 组件，接收 shop 对象作为 props
export default function ShopCard({ shop }: { shop: Shop }) {
  // 第7行：获取图片完整 URL
  const imageUrl = getImageUrl(shop.image);

  return (
    // 第10-13行：整个卡片是一个链接
    <Link
      href={`/shop/${shop.id}`}
      className="group bg-white rounded-xl overflow-hidden shadow-sm hover:shadow-lg transition-all duration-300 border border-gray-100"
      // group：子元素可用 group-hover: 响应
      // overflow-hidden：图片圆角裁切
      // transition-all：所有属性平滑过渡
    >
      {/* 第14-24行：图片区域 */}
      <div className="relative h-44 overflow-hidden bg-gray-100">
        <img
          src={imageUrl}
          alt={shop.name}
          loading="lazy"
          // loading="lazy"：懒加载（滚动到视线才加载）
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
          // object-cover：填充裁剪
          // group-hover:scale-105：鼠标悬停时放大 5%
        />
        {/* 第21-23行：价格标签（左上角） */}
        <div className="absolute top-3 left-3 bg-orange-500 text-white text-xs px-2 py-1 rounded-full">
          {shop.price_range}
        </div>
      </div>

      {/* 第25-43行：文字信息区域 */}
      <div className="p-4">
        {/* 商家名称 */}
        <h3 className="font-semibold text-gray-900 text-base truncate group-hover:text-orange-500 transition-colors">
          {/* truncate：超长文字省略号 */}
          {shop.name}
        </h3>
        {/* 评分 + 评价数 */}
        <div className="mt-1">
          <StarRating rating={shop.rating} />
          <span className="text-xs text-gray-500 ml-1">
            {shop.review_count.toLocaleString()}条评价
          </span>
        </div>
        {/* 标签 */}
        <div className="mt-2 flex flex-wrap gap-1">
          {shop.tags.slice(0, 2).map((tag) => (
            // 只显示前 2 个标签
            <span key={tag} className="text-xs bg-orange-50 text-orange-600 px-2 py-0.5 rounded">
              {tag}
            </span>
          ))}
        </div>
        {/* 地址 */}
        <p className="mt-2 text-xs text-gray-500 truncate">📍 {shop.address}</p>
      </div>
    </Link>
  );
}
```

---

# 📖 文件 8: src/components/CategoryFilter.tsx

**作用**：分类筛选按钮组（首页中部）

```tsx
// 第1行：从 types 导入分类数据
import { categories } from '@/types';

// 第3-6行：组件 props 接口
interface CategoryFilterProps {
  selected: string;       // 当前选中的分类 id
  onSelect: (id: string) => void;  // 切换分类的回调
}

// 第8行：CategoryFilter 组件
export default function CategoryFilter({ selected, onSelect }: CategoryFilterProps) {
  return (
    // 第10行：横向可滚动容器
    <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
      {/* overflow-x-auto：横向滚动
          scrollbar-hide：隐藏滚动条 */}
      {categories.map((cat) => (
        <button
          key={cat.id}
          onClick={() => onSelect(cat.id)}
          className={`flex-shrink-0 px-4 py-2 rounded-full text-sm font-medium transition-all ${
            selected === cat.id
              ? 'bg-orange-500 text-white shadow-md'
              : 'bg-white text-gray-600 hover:bg-orange-50 hover:text-orange-500 border border-gray-200'
          }`}
          // flex-shrink-0：不收缩，保持原宽
          // 选中态：橙色背景+白色文字+阴影
          // 未选中：白底灰字+边框
        >
          <span className="mr-1">{cat.icon}</span>
          {cat.name}
        </button>
      ))}
    </div>
  );
}
```

---

# 📖 文件 9: src/components/StarRating.tsx

**作用**：星级评分显示（5 颗星，支持半星）

```tsx
// 第1-4行：props 接口
interface StarRatingProps {
  rating: number;              // 评分（0-5，支持小数）
  size?: 'sm' | 'md' | 'lg';  // 可选尺寸
}

// 第6行：StarRating 组件
export default function StarRating({ rating, size = 'sm' }: StarRatingProps) {
  // 第7行：根据 size 计算 Tailwind 尺寸类
  const sizeClass = size === 'sm' ? 'w-4 h-4' : size === 'md' ? 'w-5 h-5' : 'w-6 h-6';
  // sm: 16px, md: 20px, lg: 24px

  const starCount = 5;

  return (
    <div className="inline-flex items-center gap-0.5">
      {/* 第12-25行：渲染 5 颗星 */}
      {Array.from({ length: starCount }, (_, i) => {
        // Array.from({length: 5}, (_, i) => ...)：生成 [0,1,2,3,4]
        const filled = rating >= i + 1;        // 整星：评分 >= 当前位置
        const half = !filled && rating >= i + 0.5; // 半星：评分 >= 当前位置+0.5
        return (
          <svg
            key={i}
            className={`${sizeClass} ${filled || half ? 'text-yellow-400' : 'text-gray-300'}`}
            // filled || half：黄色；否则灰色
            fill="currentColor"
            viewBox="0 0 20 20"
          >
            {/* 标准五角星 SVG 路径 */}
            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
          </svg>
        );
      })}
      {/* 第26行：显示评分数值 */}
      <span className="ml-1 text-sm font-semibold text-gray-700">{rating.toFixed(1)}</span>
    </div>
  );
}
```

---

# 📖 文件 10: src/components/ReviewForm.tsx

**作用**：发表评价的表单（商家详情页右侧）

```tsx
// 第1行：客户端组件声明
'use client';

// 第3行：导入 useState
import { useState } from 'react';

// 第5-8行：props 接口
interface ReviewFormProps {
  onSubmit: (data: { rating: number; content: string; username: string }) => Promise<void>;
  submitting?: boolean;  // 是否正在提交
}

// 第10行：ReviewForm 组件
export default function ReviewForm({ onSubmit, submitting = false }: ReviewFormProps) {
  // 第11-14行：表单状态
  const [rating, setRating] = useState(5);       // 选中的评分（默认5星）
  const [content, setContent] = useState('');    // 评价内容
  const [username, setUsername] = useState('');  // 昵称
  const [hoveredStar, setHoveredStar] = useState(0); // 鼠标悬停的星数（预览用）

  // 第16-25行：表单提交处理
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!content.trim() || !username.trim()) return;
    await onSubmit({ rating, content, username });
    // 提交后重置表单
    setContent('');
    setUsername('');
    setRating(5);
  };

  return (
    <form onSubmit={handleSubmit} className="bg-white rounded-xl p-5 border border-gray-100">
      <h3 className="font-semibold text-gray-900 mb-4">发表评价</h3>

      {/* 第30-56行：评分选择（可交互的5颗星） */}
      <div className="mb-4">
        <label className="block text-sm text-gray-600 mb-2">你的评分</label>
        <div className="flex items-center gap-1">
          {[1, 2, 3, 4, 5].map((star) => (
            <button
              key={star}
              type="button"
              onClick={() => setRating(star)}
              onMouseEnter={() => setHoveredStar(star)}
              onMouseLeave={() => setHoveredStar(0)}
              disabled={submitting}
              className="p-0.5 disabled:opacity-50"
            >
              <svg
                className={`w-8 h-8 transition-colors ${
                  (hoveredStar || rating) >= star ? 'text-yellow-400' : 'text-gray-300'
                }`}
                // 悬停时显示悬停星数，否则显示选中星数
                fill="currentColor"
                viewBox="0 0 20 20"
              >
                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
              </svg>
            </button>
          ))}
          <span className="ml-2 text-sm text-gray-500">{rating}分</span>
        </div>
      </div>

      {/* 昵称输入 */}
      <div className="mb-4">
        <label className="block text-sm text-gray-600 mb-2">昵称</label>
        <input type="text" value={username} onChange={(e) => setUsername(e.target.value)}
          placeholder="请输入昵称" disabled={submitting}
          className="w-full px-4 py-2 rounded-lg border border-gray-200 focus:border-orange-500 focus:outline-none focus:ring-1 focus:ring-orange-500 text-sm disabled:bg-gray-50" />
      </div>

      {/* 评价内容文本域 */}
      <div className="mb-4">
        <label className="block text-sm text-gray-600 mb-2">评价内容</label>
        <textarea value={content} onChange={(e) => setContent(e.target.value)}
          placeholder="分享你的体验..." rows={4} disabled={submitting}
          className="w-full px-4 py-2 rounded-lg border border-gray-200 focus:border-orange-500 focus:outline-none focus:ring-1 focus:ring-orange-500 text-sm resize-none disabled:bg-gray-50" />
          {/* resize-none：禁止拖动改变大小 */}
      </div>

      {/* 提交按钮 */}
      <button type="submit"
        disabled={submitting || !content.trim() || !username.trim()}
        // 提交中或内容为空时禁用
        className="w-full py-3 bg-orange-500 text-white rounded-lg font-medium hover:bg-orange-600 transition-colors disabled:bg-gray-300 disabled:cursor-not-allowed flex items-center justify-center gap-2">
        {submitting ? (
          // 提交中显示 loading 动画
          <>
            <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
            提交中...
          </>
        ) : (
          '提交评价'
        )}
      </button>
    </form>
  );
}
```

---

# 📖 文件 11: src/components/ReviewList.tsx

**作用**：评价列表展示（商家详情页左侧）

```tsx
// 第1行：导入 StarRating 组件
import StarRating from './StarRating';

// 第2行：导入 Review 类型
import type { Review } from '@/types';

// 第4行：ReviewList 组件
export default function ReviewList({ reviews }: { reviews: Review[] }) {
  // 第5-12行：空数据处理
  if (reviews.length === 0) {
    return (
      <div className="text-center py-12 text-gray-400">
        <p className="text-lg">暂无评价</p>
        <p className="text-sm mt-2">成为第一个评价的人吧！</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* 第16-32行：遍历渲染每条评价 */}
      {reviews.map((review) => (
        <div key={review.id} className="bg-white rounded-xl p-4 border border-gray-100">
          {/* 用户信息行 */}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              {/* 头像（取用户名首字） */}
              <div className="w-10 h-10 rounded-full bg-orange-100 flex items-center justify-center text-orange-500 font-bold">
                {review.username.charAt(0)}
              </div>
              <div>
                <p className="font-medium text-gray-900">{review.username}</p>
                <p className="text-xs text-gray-400">{review.date}</p>
              </div>
            </div>
            <StarRating rating={review.rating} size="sm" />
          </div>
          {/* 评价内容 */}
          <p className="mt-3 text-gray-700 leading-relaxed text-sm">{review.content}</p>
        </div>
      ))}
    </div>
  );
}
```

---

# 📖 文件 12: src/components/LoadingSpinner.tsx

**作用**：加载中动画（转圈）

```tsx
// 第1行：LoadingSpinner 组件
export default function LoadingSpinner({ text = '加载中...' }: { text?: string }) {
  return (
    <div className="flex flex-col items-center justify-center py-12">
      {/* 转圈动画：橙色边框 + 上半部分橙色 + 旋转 */}
      <div className="w-10 h-10 border-3 border-orange-200 border-t-orange-500 rounded-full animate-spin" />
      {/* border-3：3px 边框（通过下方 style 定义）
          border-orange-200：浅橙底
          border-t-orange-500：顶部深色（形成进度感）
          animate-spin：旋转动画 */}
      <p className="mt-3 text-sm text-gray-500">{text}</p>
      <style>{`
        .border-3 { border-width: 3px; }
      `}</style>
    </div>
  );
}
```

---

# 📖 文件 13: src/components/Toast.tsx

**作用**：顶部弹出提示气泡（操作反馈）

```tsx
// 第1行：客户端组件
'use client';

// 第3行：导入 useEffect
import { useEffect } from 'react';

// 第5-9行：props 接口
interface ToastProps {
  message: string;                              // 提示内容
  type?: 'success' | 'error' | 'loading';      // 提示类型
  onClose: () => void;                          // 关闭回调
}

// 第11行：Toast 组件
export default function Toast({ message, type = 'success', onClose }: ToastProps) {
  // 第12-17行：自动关闭逻辑
  useEffect(() => {
    if (type !== 'loading') {
      const timer = setTimeout(onClose, 2500);  // 2.5 秒后自动关闭
      return () => clearTimeout(timer);         // 清理定时器
    }
  }, [type, onClose]);

  // 第19-24行：根据类型选择背景色
  const bgClass =
    type === 'success' ? 'bg-green-500' :
    type === 'error' ? 'bg-red-500' : 'bg-gray-800';

  // 第26-27行：根据类型选择图标
  const icon =
    type === 'success' ? '✓' :
    type === 'error' ? '✕' : '⏳';

  return (
    // 第30行：固定在顶部居中
    <div className="fixed top-20 left-1/2 -translate-x-1/2 z-[100] animate-[fadeIn_0.2s_ease-out]">
      {/* animate-[fadeIn...]：自定义淡入动画 */}
      <div className={`${bgClass} text-white px-5 py-3 rounded-full shadow-lg flex items-center gap-2 text-sm font-medium`}>
        <span className="text-base">{icon}</span>
        {message}
      </div>
      {/* 第37-42行：内联动画关键帧 */}
      <style>{`
        @keyframes fadeIn {
          from { opacity: 0; transform: translate(-50%, -10px); }
          to { opacity: 1; transform: translate(-50%, 0); }
        }
      `}</style>
    </div>
  );
}
```

---

# 📖 文件 14: src/app/page.tsx

**作用**：首页（数据加载 + 搜索过滤 + 渲染）

```tsx
// ========== 导入部分 ==========
'use client';  // 声明为客户端组件

// React Hooks
import { Suspense, useState, useEffect, useMemo, useCallback } from 'react';
// Suspense：等待子组件
// useState：状态管理
// useEffect：副作用
// useMemo：缓存计算
// useCallback：缓存函数

// Next.js 导航
import { useSearchParams, useRouter } from 'next/navigation';

// 自定义组件
import Header from '@/components/Header';
import CategoryFilter from '@/components/CategoryFilter';
import ShopCard from '@/components/ShopCard';
import LoadingSpinner from '@/components/LoadingSpinner';
import Toast from '@/components/Toast';

// 类型
import type { Shop } from '@/types';

// ========== 主组件（Suspense 包装） ==========

// 第12-18行：外层组件（包装 Suspense）
export default function HomePage() {
  return (
    <Suspense fallback={<LoadingSpinner text="加载中..." />}>
      <HomeContent />
    </Suspense>
  );
}

// ========== 实际内容组件 ==========

// 第20行：HomeContent 组件
function HomeContent() {
  // 第21行：读取 URL 参数（?category=xxx）
  const searchParams = useSearchParams();
  // 第22行：获取路由器
  const router = useRouter();

  // 第23-25行：当前分类状态（初始值从 URL 读取）
  const [activeCategory, setActiveCategory] = useState(
    searchParams.get('category') || 'all'
  );
  // 第26行：搜索输入框的值
  const [searchInput, setSearchInput] = useState('');
  // 第27行：所有商家数据（一次性加载）
  const [shops, setShops] = useState<Shop[]>([]);
  // 第28行：是否已加载完成
  const [loaded, setLoaded] = useState(false);
  // 第29行：错误信息
  const [error, setError] = useState<string | null>(null);
  // 第30行：Toast 提示
  const [toast, setToast] = useState<{ message: string; type: 'success' | 'error' } | null>(null);

  // ========== 数据加载（只执行 1 次） ==========

  // 第33-48行：useEffect 只在挂载时执行
  useEffect(() => {
    const fetchAll = async () => {
      try {
        const res = await fetch('/api/shops');   // 调用后端 API
        if (!res.ok) throw new Error((await res.json()).error || '加载失败');
        const data = await res.json();             // 解析 JSON
        setShops(data.shops || []);                // 存入 state
      } catch (e: any) {
        setError(e.message);
        setToast({ message: e.message, type: 'error' });
      } finally {
        setLoaded(true);  // 无论成败都标记完成
      }
    };
    fetchAll();
  }, []);  // [] = 无依赖，只执行 1 次

  // ========== 搜索防抖 ==========

  // 第51行：防抖后的搜索词
  const [debouncedQuery, setDebouncedQuery] = useState('');

  // 第52-55行：输入停止 200ms 后才更新搜索词
  useEffect(() => {
    const t = setTimeout(() => setDebouncedQuery(searchInput.trim().toLowerCase()), 200);
    return () => clearTimeout(t);  // 新输入时取消旧定时器
  }, [searchInput]);

  // ========== 本地过滤（零延迟） ==========

  // 第58-79行：useMemo 缓存过滤结果
  const filteredShops = useMemo(() => {
    let result = shops;

    // 分类过滤
    if (activeCategory !== 'all') {
      result = result.filter((s) => s.category === activeCategory);
    }

    // 关键词搜索
    if (debouncedQuery) {
      result = result.filter((s) => {
        const q = debouncedQuery;
        return (
          s.name.toLowerCase().includes(q) ||        // 名字包含
          s.address?.toLowerCase().includes(q) ||    // 地址包含
          s.tags?.some((t) => t.toLowerCase().includes(q))  // 标签包含
        );
      });
    }

    return result;
  }, [shops, activeCategory, debouncedQuery]);
  // 依赖变化时才重新计算

  // ========== 事件处理 ==========

  // 第82-88行：切换分类
  const handleCategoryChange = useCallback(
    (id: string) => {
      setActiveCategory(id);
      // 更新 URL（不刷新页面）
      router.push(id === 'all' ? '/' : `/?category=${id}`, { scroll: false });
    },
    [router]
  );

  // 第91-93行：搜索提交
  const handleSearch = () => {
    setDebouncedQuery(searchInput.trim().toLowerCase());
  };

  // ========== 渲染部分 ==========

  return (
    <div className="min-h-screen bg-gray-50">
      {/* 顶部导航栏 */}
      <Header />

      {/* Toast 提示 */}
      {toast && (
        <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />
      )}

      {/* Hero 搜索区 */}
      <section className="bg-gradient-to-r from-orange-500 to-red-500 py-12">
        <div className="max-w-7xl mx-auto px-4 text-center">
          <h1 className="text-4xl font-bold text-white mb-4">发现身边的精彩</h1>
          <p className="text-white/80 text-lg mb-8">真实评价 · 精选推荐 · 吃喝玩乐全覆盖</p>
          {/* 搜索框 */}
          <div className="max-w-2xl mx-auto relative">
            <input type="text" value={searchInput}
              onChange={(e) => setSearchInput(e.target.value)}
              placeholder="搜索商家、菜品、地址..."
              className="w-full pl-12 pr-32 py-4 rounded-full text-gray-800 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-white/50 shadow-lg" />
            {/* 搜索图标 SVG */}
            <svg className="absolute left-5 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"
              fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <button onClick={handleSearch}
              className="absolute right-2 top-1/2 -translate-y-1/2 bg-orange-500 text-white px-6 py-2 rounded-full font-medium hover:bg-orange-600 transition-colors">
              搜索
            </button>
          </div>
        </div>
      </section>

      {/* 分类筛选 */}
      <section className="max-w-7xl mx-auto px-4 py-6">
        <CategoryFilter selected={activeCategory} onSelect={handleCategoryChange} />
      </section>

      {/* 结果列表 */}
      <section className="max-w-7xl mx-auto px-4 pb-16">
        {/* 标题栏 */}
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-bold text-gray-900">
            {activeCategory === 'all' ? '热门推荐' : getCategoryName(activeCategory)}
            <span className="ml-2 text-sm font-normal text-gray-500">
              共 {filteredShops.length} 家
            </span>
          </h2>
        </div>

        {/* 三种状态 */}
        {!loaded ? (
          <LoadingSpinner text="正在加载商家..." />
        ) : error ? (
          // 错误状态
          <div className="text-center py-16 bg-white rounded-xl">
            <p className="text-red-500 text-lg mb-2">⚠️ 加载失败</p>
            <p className="text-gray-500 text-sm mb-4">{error}</p>
            <button onClick={() => window.location.reload()}
              className="px-4 py-2 bg-orange-500 text-white rounded-full text-sm hover:bg-orange-600">
              重试
            </button>
          </div>
        ) : filteredShops.length === 0 ? (
          // 空数据状态
          <div className="text-center py-16 bg-white rounded-xl">
            <p className="text-gray-400 text-lg">没有找到相关商家</p>
            <p className="text-gray-400 text-sm mt-2">试试其他关键词吧</p>
          </div>
        ) : (
          // 正常列表
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
            {/* 响应式：手机1列/平板2列/笔记本3列/桌面4列 */}
            {filteredShops.map((shop) => (
              <ShopCard key={shop.id} shop={shop} />
            ))}
          </div>
        )}
      </section>

      {/* 页脚 */}
      <footer className="bg-gray-900 text-gray-400 py-8">
        <div className="max-w-7xl mx-auto px-4 text-center text-sm">
          <p>© 2026 点评网 Demo · 仅作演示用途</p>
        </div>
      </footer>
    </div>
  );
}

// 第197-208行：分类 ID → 中文名映射
function getCategoryName(id: string): string {
  const map: Record<string, string> = {
    food: '美食',
    movie: '电影',
    hotel: '酒店',
    shopping: '购物',
    hair: '丽人',
    sport: '运动',
    study: '学习',
  };
  return map[id] || '分类结果';
}
```

---

# 📖 文件 15: src/app/shop/[id]/page.tsx

**作用**：商家详情页（展示商家信息 + 评价 + 发表评价）

```tsx
// ========== 导入 ==========
'use client';

import { useState, useEffect, useCallback } from 'react';
import { useParams } from 'next/navigation';  // 读取 URL 参数（[id]）
import Link from 'next/link';
import Header from '@/components/Header';
import StarRating from '@/components/StarRating';
import ReviewList from '@/components/ReviewList';
import ReviewForm from '@/components/ReviewForm';
import LoadingSpinner from '@/components/LoadingSpinner';
import Toast from '@/components/Toast';
import type { Shop, Review } from '@/types';
import { getImageUrl } from '@/lib/storage';

// 第15行：ShopDetailPage 组件
export default function ShopDetailPage() {
  // 第16-17行：从 URL 读取 id 参数
  const params = useParams();
  const shopId = Number(params.id);  // 转为数字

  // 第19-24行：状态定义
  const [shop, setShop] = useState<Shop | null>(null);       // 商家数据
  const [reviews, setReviews] = useState<Review[]>([]);     // 评价列表
  const [loading, setLoading] = useState(true);              // 加载状态
  const [submitting, setSubmitting] = useState(false);       // 提交中状态
  const [error, setError] = useState<string | null>(null);   // 错误信息
  const [toast, setToast] = useState<{ message: string; type: 'success' | 'error' } | null>(null);

  // ========== 数据获取 ==========

  // 第26-48行：fetchShop 函数（缓存，避免重复创建）
  const fetchShop = useCallback(async () => {
    setLoading(true);
    try {
      // 第29-32行：并行请求商家信息和评价列表
      const [shopRes, reviewsRes] = await Promise.all([
        fetch(`/api/shops/${shopId}`),
        fetch(`/api/shops/${shopId}/reviews`),
      ]);
      // Promise.all：同时发请求，等全部完成

      // 第34-37行：检查商家请求
      if (!shopRes.ok) {
        const err = await shopRes.json();
        throw new Error(err.error || '商家不存在');
      }
      const shopData = await shopRes.json();
      setShop(shopData.shop);

      // 第41-42行：解析评价
      const reviewsData = await reviewsRes.json();
      setReviews(reviewsData.reviews || []);
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }, [shopId]);

  // 第50-52行：shopId 有效时执行加载
  useEffect(() => {
    if (!Number.isNaN(shopId)) fetchShop();
  }, [shopId, fetchShop]);

  // ========== 提交评价 ==========

  // 第54-83行：handleAddReview 函数
  const handleAddReview = async (data: { rating: number; content: string; username: string }) => {
    setSubmitting(true);
    setToast({ message: '正在提交评价...', type: 'success' });
    try {
      const res = await fetch(`/api/shops/${shopId}/reviews`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });

      if (!res.ok) {
        const err = await res.json();
        throw new Error(err.error || '提交失败');
      }

      const result = await res.json();
      // 第74行：把新评价加到列表最前面
      setReviews((prev) => [result.review, ...prev]);
      setToast({ message: '评价提交成功！', type: 'success' });
      // 第77行：重新拉取商家信息（更新平均分）
      fetchShop();
    } catch (e: any) {
      setToast({ message: `提交失败: ${e.message}`, type: 'error' });
    } finally {
      setSubmitting(false);
    }
  };

  // ========== 条件渲染 ==========

  // 第85-101行：错误/不存在状态
  if (Number.isNaN(shopId) || (!loading && error && !shop)) {
    return (
      <div className="min-h-screen bg-gray-50">
        <Header />
        <div className="max-w-7xl mx-auto px-4 py-16 text-center">
          <h1 className="text-2xl font-bold text-gray-900">商家未找到</h1>
          <p className="text-gray-500 mt-2">{error}</p>
          <Link href="/" className="mt-4 inline-block text-orange-500 hover:underline">
            返回首页
          </Link>
        </div>
      </div>
    );
  }

  // 第103-110行：加载中状态
  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50">
        <Header />
        <LoadingSpinner text="正在加载商家详情..." />
      </div>
    );
  }

  // 第112行：空值保护
  if (!shop) return null;

  // ========== 正常渲染 ==========
  return (
    <div className="min-h-screen bg-gray-50">
      <Header />

      {/* Toast */}
      {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}

      {/* 返回链接 */}
      <div className="max-w-7xl mx-auto px-4 py-4">
        <Link href="/" className="text-sm text-gray-500 hover:text-orange-500 flex items-center gap-1">
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
          返回列表
        </Link>
      </div>

      {/* 商家信息卡片 */}
      <section className="max-w-7xl mx-auto px-4 pb-8">
        <div className="bg-white rounded-2xl overflow-hidden shadow-sm border border-gray-100">
          {/* 封面图 */}
          <div className="h-64 bg-gray-200 overflow-hidden">
            <img src={getImageUrl(shop.image)} alt={shop.name} className="w-full h-full object-cover" />
          </div>

          <div className="p-6">
            {/* 标题行 */}
            <div className="flex items-start justify-between">
              <div>
                <h1 className="text-2xl font-bold text-gray-900">{shop.name}</h1>
                <div className="mt-2 flex items-center gap-4">
                  <StarRating rating={shop.rating} size="md" />
                  <span className="text-sm text-gray-500">{shop.review_count.toLocaleString()}条评价</span>
                </div>
              </div>
              <div className="text-right">
                <span className="text-lg font-semibold text-orange-500">{shop.price_range}</span>
              </div>
            </div>

            {/* 标签 */}
            <div className="mt-4 flex flex-wrap gap-2">
              {shop.tags.map((tag) => (
                <span key={tag} className="px-3 py-1 bg-orange-50 text-orange-600 text-sm rounded-full">
                  {tag}
                </span>
              ))}
            </div>

            {/* 描述 */}
            <div className="mt-6 p-4 bg-gray-50 rounded-xl">
              <p className="text-gray-700 text-sm leading-relaxed">{shop.description}</p>
            </div>

            {/* 三列信息 */}
            <div className="mt-6 grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 rounded-lg bg-orange-50 flex items-center justify-center text-lg">📍</div>
                <div>
                  <p className="text-xs text-gray-400">地址</p>
                  <p className="text-sm text-gray-700">{shop.address}</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 rounded-lg bg-orange-50 flex items-center justify-center text-lg">📞</div>
                <div>
                  <p className="text-xs text-gray-400">电话</p>
                  <p className="text-sm text-gray-700">{shop.phone}</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 rounded-lg bg-orange-50 flex items-center justify-center text-lg">🕐</div>
                <div>
                  <p className="text-xs text-gray-400">营业时间</p>
                  <p className="text-sm text-gray-700">{shop.hours}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 评价区 */}
      <section className="max-w-7xl mx-auto px-4 pb-16">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2">
            <h2 className="text-xl font-bold text-gray-900 mb-4">
              用户评价
              <span className="ml-2 text-sm font-normal text-gray-500">({reviews.length})</span>
            </h2>
            <ReviewList reviews={reviews} />
          </div>
          <div>
            <ReviewForm onSubmit={handleAddReview} submitting={submitting} />
          </div>
        </div>
      </section>

      {/* 页脚 */}
      <footer className="bg-gray-900 text-gray-400 py-8">
        <div className="max-w-7xl mx-auto px-4 text-center text-sm">
          <p>© 2026 点评网 Demo · 仅作演示用途</p>
        </div>
      </footer>
    </div>
  );
}
```

---

# 📖 文件 16: src/app/api/shops/route.ts

**作用**：商家列表 API（`GET /api/shops`）

```ts
import { NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';
import type { Shop } from '@/types';

export const dynamic = 'force-dynamic';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const category = searchParams.get('category') || 'all';
    const q = searchParams.get('q') || '';
    const keyword = q.trim();

    // 有搜索关键词 → 三路并发搜索
    if (keyword) {
      const tasks = [
        supabase.from('shops').select('*').ilike('name', `*${keyword}*`),
        supabase.from('shops').select('*').ilike('address', `*${keyword}*`),
        supabase.from('shops').select('*').contains('tags', [keyword]),
      ];
      const results = await Promise.all(tasks);

      // 合并结果
      const all: Shop[] = [];
      for (const { data, error } of results) {
        if (error) console.warn('Search error:', error.message);
        else if (data) all.push(...(data as Shop[]));
      }

      // 去重
      const seen = new Set<number>();
      let merged = all.filter((s) => {
        if (seen.has(s.id)) return false;
        seen.add(s.id);
        return true;
      });

      // 分类过滤
      if (category !== 'all') {
        merged = merged.filter((s) => s.category === category);
      }

      // 按评分排序
      merged.sort((a, b) => b.rating - a.rating);
      return NextResponse.json({ shops: merged });
    }

    // 无关键词 → 简单列表
    let query = supabase.from('shops').select('*').order('rating', { ascending: false });
    if (category !== 'all') query = query.eq('category', category);

    const { data, error } = await query;
    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }
    return NextResponse.json({ shops: (data as Shop[]) || [] });
  } catch (e: any) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}
```

---

# 📖 文件 17: src/app/api/shops/[id]/route.ts

**作用**：单个商家 API

```ts
import { NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';
import type { Shop } from '@/types';

export const dynamic = 'force-dynamic';

export async function GET(_request: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    const { id } = await params;
    const shopId = Number(id);
    if (Number.isNaN(shopId)) {
      return NextResponse.json({ error: '无效的商家ID' }, { status: 400 });
    }
    const { data, error } = await supabase
      .from('shops').select('*').eq('id', shopId).single();
    if (error) {
      return NextResponse.json({ error: error.message }, { status: 404 });
    }
    return NextResponse.json({ shop: data as Shop });
  } catch (e: any) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}
```

---

# 📖 文件 18: src/app/api/shops/[id]/reviews/route.ts

**作用**：评价 API（GET 列表 + POST 新增）

```ts
import { NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';
import type { Review } from '@/types';

export const dynamic = 'force-dynamic';

// GET：获取评价列表
export async function GET(_request: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    const { id } = await params;
    const shopId = Number(id);
    if (Number.isNaN(shopId)) {
      return NextResponse.json({ error: '无效的商家ID' }, { status: 400 });
    }
    const { data, error } = await supabase
      .from('reviews').select('*').eq('shop_id', shopId)
      .order('created_at', { ascending: false });
    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }
    return NextResponse.json({ reviews: (data as Review[]) || [] });
  } catch (e: any) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}

// POST：新增评价 + 更新平均分
export async function POST(request: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    const { id } = await params;
    const shopId = Number(id);
    if (Number.isNaN(shopId)) {
      return NextResponse.json({ error: '无效的商家ID' }, { status: 400 });
    }
    const body = await request.json();
    const { username, rating, content } = body;

    // 校验
    if (!username?.trim() || !content?.trim()) {
      return NextResponse.json({ error: '昵称和评价内容不能为空' }, { status: 400 });
    }
    if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
      return NextResponse.json({ error: '评分必须是 1-5 的整数' }, { status: 400 });
    }

    // 插入评价
    const { data: newReview, error: insertError } = await supabase
      .from('reviews')
      .insert({ shop_id: shopId, username: username.trim(), rating, content: content.trim() })
      .select().single();
    if (insertError) {
      return NextResponse.json({ error: insertError.message }, { status: 500 });
    }

    // 更新商家平均分
    const { data: stats } = await supabase
      .from('reviews').select('rating').eq('shop_id', shopId);
    if (stats && stats.length > 0) {
      const avgRating = stats.reduce((sum, r) => sum + r.rating, 0) / stats.length;
      await supabase.from('shops').update({
        rating: Math.round(avgRating * 10) / 10,
        review_count: stats.length,
      }).eq('id', shopId);
    }

    return NextResponse.json({ review: newReview as Review }, { status: 201 });
  } catch (e: any) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}
```

---

# 📖 文件 19: supabase_init.sql

**作用**：数据库初始化脚本

```sql
-- 1. 创建 Storage 存储桶 shop-images
-- 2. 配置 Storage RLS 策略（读/写/删）
-- 3. 创建 shops 表（商家信息）
-- 4. 创建 reviews 表（评价信息）
-- 5. 启用 RLS + 配置匿名访问策略
-- 6. 插入 8 家示例商家
-- 7. 插入 5 条示例评价
```

---

# 📖 文件 20: .env.local.example

**作用**：环境变量模板

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
```

---

## 📊 项目文件清单

| # | 文件 | 作用 |
|---|------|------|
| 1 | `src/app/layout.tsx` | 根布局 |
| 2 | `src/app/globals.css` | 全局样式 |
| 3 | `src/lib/supabase.ts` | 数据库连接 |
| 4 | `src/lib/storage.ts` | 图片 URL 处理 |
| 5 | `src/types/index.ts` | 类型定义 |
| 6 | `src/components/Header.tsx` | 导航栏+登录 |
| 7 | `src/components/ShopCard.tsx` | 商家卡片 |
| 8 | `src/components/CategoryFilter.tsx` | 分类筛选 |
| 9 | `src/components/StarRating.tsx` | 星级评分 |
| 10 | `src/components/ReviewForm.tsx` | 评价表单 |
| 11 | `src/components/ReviewList.tsx` | 评价列表 |
| 12 | `src/components/LoadingSpinner.tsx` | 加载动画 |
| 13 | `src/components/Toast.tsx` | 提示气泡 |
| 14 | `src/app/page.tsx` | 首页 |
| 15 | `src/app/shop/[id]/page.tsx` | 商家详情 |
| 16 | `src/app/api/shops/route.ts` | 商家列表 API |
| 17 | `src/app/api/shops/[id]/route.ts` | 单个商家 API |
| 18 | `src/app/api/shops/[id]/reviews/route.ts` | 评价 API |
| 19 | `supabase_init.sql` | 数据库脚本 |
| 20 | `.env.local.example` | 环境变量模板 |

**总计：20 个文件，约 1600 行代码**