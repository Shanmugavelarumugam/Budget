# 🌐 Resend Domain Setup - shanmugavel.ct.ws

## ✅ **Domain Added to Resend**

Your domain: `shanmugavel.ct.ws` (Tokyo region)

---

## 📋 **DNS Records to Add**

You need to add these records to your domain provider (wherever you registered `shanmugavel.ct.ws`).

### **1. DKIM (Domain Verification)** ⚠️ REQUIRED

| Type | Name | Content | TTL |
|------|------|---------|-----|
| **TXT** | `resend._domainkey.shanmugavel` | `p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCv/vdeQb1ZUSDIZaXTJVRfBqcm4iqVrkJ0VzyXbakgToLIt62Fu3Gw6eVRCMsi9uYj1l408GpT3eFhmVeluGMvRgGuFe8sq7HgsNN6TxO8Q2l9Npwfg5ePupzBuPxKZfX74ulNShHaS89tck6rdLk13xBNxH1DKceOZcfcJGXhKQIDAQAB` | Auto |

### **2. SPF (Sending Permission)** ⚠️ REQUIRED

| Type | Name | Content | TTL | Priority |
|------|------|---------|-----|----------|
| **MX** | `send.shanmugavel` | `feedback-smtp.ap-northeast-1.amazonses.com` | Auto | 10 |
| **TXT** | `send.shanmugavel` | `v=spf1 include:amazonses.com ~all` | Auto | - |

### **3. DMARC (Optional but Recommended)**

| Type | Name | Content | TTL |
|------|------|---------|-----|
| **TXT** | `_dmarc` | `v=DMARC1; p=none;` | Auto |

---

## 🔧 **How to Add DNS Records**

### **Step 1: Find Your Domain Provider**

Where did you register `shanmugavel.ct.ws`?
- Namecheap?
- GoDaddy?
- Cloudflare?
- Freenom?
- Other?

### **Step 2: Go to DNS Management**

1. Login to your domain provider
2. Find "DNS Management" or "DNS Settings"
3. Look for "Add Record" or "Manage DNS"

### **Step 3: Add Each Record**

For each record above:
1. Click "Add Record"
2. Select the **Type** (TXT or MX)
3. Enter the **Name** (e.g., `resend._domainkey.shanmugavel`)
4. Enter the **Content** (the long text)
5. Set **TTL** to Auto or 3600
6. For MX records, set **Priority** to 10
7. Click "Save"

---

## ⏱️ **Wait for Verification**

After adding all records:
1. **Wait 5-60 minutes** for DNS propagation
2. **Go back to Resend** dashboard
3. **Check domain status** - should show "Verified"
4. **Enable sending** - Click the toggle

---

## 🎯 **After Verification**

Once verified, update your Flutter app:

### **1. Update From Email**

In `email_service.dart`, change:
```dart
static const String _fromEmail = 'onboarding@resend.dev';
```

To:
```dart
static const String _fromEmail = 'noreply@shanmugavel.ct.ws';
```

### **2. Disable Development Mode**

```dart
static const bool _isDevelopmentMode = false;
```

### **3. Test**

Now you can send to ANY email address! 🎉

---

## 🧪 **Verify DNS Records**

### **Online Tools**:
- https://mxtoolbox.com/SuperTool.aspx
- https://dnschecker.org/

Enter your domain and check if records are visible.

---

## 📊 **Common DNS Providers**

### **Namecheap**:
1. Dashboard → Domain List
2. Click "Manage" next to domain
3. Advanced DNS tab
4. Add New Record

### **Cloudflare**:
1. Select domain
2. DNS tab
3. Add record

### **GoDaddy**:
1. My Products
2. DNS
3. Add

### **Freenom**:
1. Services → My Domains
2. Manage Domain
3. Manage Freenom DNS

---

## ⚠️ **Important Notes**

### **For MX Record**:
- Name: `send.shanmugavel` (NOT `send.shanmugavel.ct.ws`)
- If your provider auto-adds the domain, just use `send`

### **For TXT Records**:
- Name: `resend._domainkey.shanmugavel` (NOT full domain)
- Content: Copy EXACTLY as shown (including `p=`)

### **TTL**:
- Use "Auto" or "3600" (1 hour)
- Lower = faster updates, higher = better caching

---

## 🔍 **Troubleshooting**

### **"Records not found"**
- Wait longer (up to 24 hours)
- Check you added to correct domain
- Verify record names are exact

### **"DKIM verification failed"**
- Check TXT record content is complete
- No extra spaces or line breaks
- Copy-paste carefully

### **"SPF check failed"**
- Verify MX record priority is 10
- Check TXT record has `v=spf1`

---

## 🎉 **After Setup**

Once verified:
- ✅ Send to ANY email address
- ✅ No development mode restrictions
- ✅ Professional sender address
- ✅ Better deliverability
- ✅ No spam folder issues

---

## 📞 **Next Steps**

1. **Add DNS records** to your domain provider
2. **Wait 30-60 minutes**
3. **Check Resend dashboard** for verification
4. **Update Flutter code** (from email)
5. **Disable development mode**
6. **Test with any email!**

---

**Add those DNS records and you'll be able to send to anyone! 🚀**
