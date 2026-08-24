# ربات رول‌پلی انیمه‌ای (تلگرام + Cloudflare Workers)

## ساختار پروژه
```
anime-rp-bot/
├── wrangler.toml       # تنظیمات Cloudflare
├── schema.sql          # اسکیمای دیتابیس D1
├── package.json
└── src/
    ├── index.js         # منطق اصلی بازی + وب‌هوک تلگرام + کرون
    ├── data.js          # لیست کرکترها و موقعیت‌ها
    ├── telegram.js       # توابع کمکی تلگرام
    └── judge.js          # فراخوانی Workers AI برای داوری
```

## پیش‌نیازها
- Node.js نصب باشه
- یک حساب رایگان Cloudflare
- یک ربات تلگرام ساخته‌شده با @BotFather (توکن رو نگه دار)

## مرحله ۱: نصب ابزارها
```bash
cd anime-rp-bot
npm install
npx wrangler login
```
این دستور یه تب مرورگر باز می‌کنه تا با حساب Cloudflare‌ت لاگین کنی.

## مرحله ۲: ساخت دیتابیس D1
```bash
npx wrangler d1 create anime-rp-bot-db
```
خروجی این دستور یه `database_id` بهت می‌ده. اون رو کپی کن و داخل فایل
`wrangler.toml` جای `REPLACE_WITH_YOUR_DATABASE_ID` بذار.

بعد اسکیما رو روی دیتابیس اجرا کن:
```bash
npx wrangler d1 execute anime-rp-bot-db --remote --file=./schema.sql
```

## مرحله ۳: فعال‌سازی Workers AI
نیازی به کار اضافه نیست — چون binding آن (`[ai]`) از قبل داخل
`wrangler.toml` تعریف شده و روی هر حساب Cloudflare رایگان در دسترسه.

## مرحله ۴: تنظیم توکن ربات به‌صورت امن (secret)
```bash
npx wrangler secret put TELEGRAM_BOT_TOKEN
```
توکنی که از BotFather گرفتی رو وارد کن.

اختیاری ولی پیشنهادی (برای امنیت وب‌هوک):
```bash
npx wrangler secret put WEBHOOK_SECRET
```
یه رشته‌ی رندوم دلخواه وارد کن (مثلاً یه پسورد بلند تصادفی) — بعداً موقع
ست کردن وب‌هوک همینو استفاده می‌کنیم.

## مرحله ۵: دیپلوی
```bash
npx wrangler deploy
```
بعد از دیپلوی، یه آدرس مثل این بهت می‌ده:
```
https://anime-rp-bot.<your-subdomain>.workers.dev
```

## مرحله ۶: وصل کردن وب‌هوک تلگرام به Worker
با مرورگر یا curl این آدرس رو باز کن (مقادیر داخل `<>` رو جایگزین کن):
```
https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/setWebhook?url=https://anime-rp-bot.<your-subdomain>.workers.dev&secret_token=<WEBHOOK_SECRET>
```
اگه `WEBHOOK_SECRET` ست نکردی، بخش `&secret_token=...` رو حذف کن.

پاسخ باید `"ok":true` باشه.

## مرحله ۷: تست
ربات رو به یه گروه تلگرام اضافه کن، ادمینش کن (برای دیدن پیام‌ها لازمه —
تو تنظیمات @BotFather گزینه‌ی Group Privacy رو هم خاموش کن تا ربات همه‌ی
پیام‌ها رو ببینه، نه فقط دستورات)، و `/game` رو بزن.

## نکات مهم
- **بازه‌ی فعال ربات**: ۱۰:۰۰ تا ۰۴:۰۰ به وقت تهران (UTC+3:30) — این تو
  کد `src/index.js` هاردکد شده (تابع `tehranHour`). اگه غلطه یا می‌خوای
  عوضش کنی، همون‌جا قابل تغییره.
- **مدل AI**: `@cf/meta/llama-3.1-8b-instruct` — رایگان و تو سهمیه‌ی
  ۱۰,۰۰۰ نورون روزانه‌ی Cloudflare جا می‌شه. برای عوض کردنش، مقدار
  `MODEL` تو فایل `src/judge.js` رو تغییر بده.
- **کرون**: هر ۱ دقیقه یه‌بار اجرا می‌شه تا مهلت‌های ۱۰ دقیقه‌ای و ۳۰
  دقیقه‌ای رو چک کنه. این تو پلن رایگان Cloudflare Workers مجازه.
- هر گروه کاملاً مستقل عمل می‌کنه: بازی، امتیاز، و کول‌داون هرکدوم بر
  اساس `chat_id` جدا نگه داشته می‌شن.

## نکاتی که در آینده می‌تونی اضافه کنی
- ذخیره‌ی تاریخچه‌ی بازی‌های قبلی برای جلوگیری از تکرار نزدیک کرکتر/موقعیت
- افزودن جدول امتیازات هفتگی جدا از جدول کلی
- اعلام نتیجه با ذکر کرکتر و موقعیت‌های پیشین در پیام‌های تشویقی
