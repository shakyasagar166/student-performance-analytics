# Cloud Deployment Guide — Live Public URL Setup
## Student Performance Analytics Web Platform
**Author / Creator:** Uncodemy Student  
**Target:** Make the application accessible online 24/7 to anyone worldwide via a public web link.

---

## 🚀 Option 1: Render.com (Recommended — 100% Free, No Credit Card)

Render is the easiest, most reliable cloud platform to host this Python full-stack project for free. It automatically builds your code from GitHub and gives you a free HTTPS public domain like:  
`https://student-performance-analytics.onrender.com`

### Step-by-Step Instructions:

#### Step 1: Push Code to GitHub
1. Open the project folder: `C:\Users\Asus\.gemini\antigravity\scratch\student-performance-analytics\`
2. Double-click **`push_to_github.bat`**.
3. Enter your GitHub repository URL (e.g., `https://github.com/YourUsername/student-performance-analytics.git`).
4. Ensure all files (including `requirements.txt`, `Procfile`, `render.yaml`, `server.py`) are pushed.

#### Step 2: Sign Up on Render
1. Go to **[https://render.com](https://render.com)**.
2. Click **"Get Started for Free"** and sign in using your **GitHub account**.

#### Step 3: Create Web Service
1. On the Render Dashboard, click the **"New +"** button at the top right and select **"Web Service"**.
2. Select **"Build and deploy from a Git repository"** and click **Next**.
3. Choose your repository: `student-performance-analytics` and click **"Connect"**.

#### Step 4: Configure Settings
Fill in these exact fields:
* **Name:** `student-performance-analytics` *(or any custom name you prefer)*
* **Region:** *Singapore* or *Frankfurt* or *Oregon* (any)
* **Branch:** `main`
* **Root Directory:** *(leave blank)*
* **Runtime:** `Python 3`
* **Build Command:** `pip install -r requirements.txt`
* **Start Command:** `python server.py`
* **Instance Type:** Select **Free** ($0 / month)

#### Step 5: Deploy!
1. Click the blue **"Deploy Web Service"** button at the bottom.
2. Render will automatically:
   - Install `pandas` and `openpyxl`.
   - Run `server.py` and bind to the cloud port.
   - Seed the 1,000-student database and Excel model.
3. Within 1–2 minutes, your service will display **"Live"** with a green badge!
4. You will get your public link at the top:
   👉 **`https://student-performance-analytics-xxxx.onrender.com`**

Anyone on the internet (interviewers, recruiters, friends) can now open that URL on their laptop, tablet, or phone to use your live dashboard, execute SQL queries, and download the Excel model!

---

## 🚆 Option 2: Railway.app (Fast 1-Click Alternative)

1. Visit **[https://railway.app](https://railway.app)** and log in with GitHub.
2. Click **"New Project"** -> **"Deploy from GitHub repo"**.
3. Select your repository `student-performance-analytics`.
4. Railway will automatically detect the `Dockerfile` or `Procfile` and deploy it.
5. In Project Settings, click **"Generate Domain"** to get a public URL like:
   👉 `https://student-performance-analytics.up.railway.app`

---

## 🐍 Option 3: PythonAnywhere (Classic Free Python Cloud)

1. Sign up for a free beginner account at **[https://www.pythonanywhere.com](https://www.pythonanywhere.com)**.
2. Open a **Bash Console** and clone your GitHub repo:
   ```bash
   git clone https://github.com/YourUsername/student-performance-analytics.git
   ```
3. Install dependencies:
   ```bash
   pip install pandas openpyxl
   ```
4. Run `python server.py` or configure a Web Tab pointing to your public domain `https://yourusername.pythonanywhere.com`.

---

## 🌐 Option 4: GitHub Pages (For Instant Static UI & Power BI Preview)

If you want a free, instant frontend link hosted directly on GitHub:
1. In your GitHub repository, go to **Settings** -> **Pages**.
2. Under **Build and deployment**, set **Source** to `Deploy from a branch`.
3. Choose Branch: `main`, Folder: `/ (root)`, and click **Save**.
4. GitHub will give you a public URL:
   👉 `https://YourUsername.github.io/student-performance-analytics/`
   *(This will allow anyone to view the dashboard and Power BI Preview tab directly).*

---

## 🎯 What to Share on Your Resume / LinkedIn

Jab aapka link live ho jaye, to aap apne resume aur LinkedIn profile par is tarah add kar sakte hain:

> **Student Performance Analytics — EdTech Business Intelligence Platform**  
> *Author: Uncodemy Student*  
> 🔗 **Live Cloud App:** `https://student-performance-analytics.onrender.com`  
> 🐙 **GitHub Repository:** `https://github.com/YourUsername/student-performance-analytics`  
> 📊 **Tech Stack:** MySQL 8.0, Microsoft Excel 365, Power BI Star Schema, Python REST API, Live SQL Execution Engine.
