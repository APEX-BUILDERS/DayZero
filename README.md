<div align="center">

# 🕐 DayZero

### One inbox for everything — auto-scheduled.

DayZero pulls action items out of your emails and meeting notes, unifies them into a single task list, and automatically schedules them into your free time — rescheduling anything you miss.

<p>
  <img src="https://img.shields.io/badge/track-Productivity-F2A93B?style=flat-square" alt="Productivity Track" />
  <img src="https://img.shields.io/badge/status-Hackathon%20MVP-1E2761?style=flat-square" alt="Status" />
  <img src="https://img.shields.io/badge/client-Flutter-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/backend-NestJS-E0234E?style=flat-square&logo=nestjs&logoColor=white" alt="NestJS" />
  <img src="https://img.shields.io/badge/database-PostgreSQL-4169E1?style=flat-square&logo=postgresql&logoColor=white" alt="PostgreSQL" />
  <img src="https://img.shields.io/badge/cache-Redis-DC382D?style=flat-square&logo=redis&logoColor=white" alt="Redis" />
  <img src="https://img.shields.io/badge/cloud-AWS-232F3E?style=flat-square&logo=amazonaws&logoColor=white" alt="AWS" />
  <img src="https://img.shields.io/badge/license-TBD-lightgrey?style=flat-square" alt="License" />
</p>

**[Problem](#-the-problem) · [Solution](#-the-solution) · [Architecture](#️-system-architecture) · [Getting Started](#-getting-started) · [API](#-api-overview) · [Deployment](#️-deployment) · [Roadmap](#️-roadmap)**

</div>

---

## 🧩 The Problem

Most people's real to-do list isn't written down anywhere. It's scattered across:

| Where it hides | Why it fails you |
|---|---|
| 📧 **Email** | Action items buried in threads you'll "get to later" |
| 🗒️ **Meetings** | Decisions and follow-ups that live only in someone's notes |
| 📅 **Calendar** | No connection between what's due and when you'll actually do it |
| 🧠 **Memory** | Mentally re-tracking tasks instead of just doing them |

Most to-do apps only solve the *last* step — tracking a task once you've already written it down. They don't solve the harder problem: **finding** the task, and **fitting it into your day**.

## 💡 The Solution

DayZero does two jobs, feeding one continuously updated plan:

<table>
<tr>
<td width="50%" valign="top">

### 📥 Capture
Reads emails and meeting notes and extracts real action items — what needs doing, by when, and who owns it.

- Email threads
- Meeting transcripts
- Manual notes

</td>
<td width="50%" valign="top">

### ⏰ Schedule
Slots every unified task into your free time, and automatically re-plans the moment something gets missed.

- Priority + deadline aware
- Fits open calendar slots
- Auto-reschedules missed tasks

</td>
</tr>
</table>

Both capture sources write to the **same task schema**, so the product needs only one dashboard and one "Today's Plan" view — not several disconnected tools.

### Who it's for

- 🎓 **Students** juggling coursework, internships, and club commitments across email and meetings
- 💼 **Freelancers & team leads** whose client calls generate follow-ups that get buried in the inbox
- 📋 **Busy professionals** who end most days saying *"I meant to get to that"*

---

## ✨ Core Features

| Feature | Description |
|---|---|
| **Email → Tasks** | Paste (or connect) an email thread; DayZero extracts action items with deadline, priority, and owner |
| **Meeting → Tasks** | Paste a meeting transcript or notes; DayZero extracts decisions and follow-ups |
| **Unified Task List** | All tasks — regardless of source — live in one schema, one dashboard |
| **Auto-Scheduling** | Tasks are automatically slotted into declared free-time blocks, sorted by priority and deadline |
| **Adaptive Rescheduling** ⭐ | Marking a task "missed" triggers an automatic re-slot into the next available block — the core differentiator of the product |
| **Source Filtering** | View tasks by origin (email / meeting / manual) or by status (pending / scheduled / done / missed) |

<div align="center">

**Before → After: the feature that sells it**

| ⏰ Today's Plan | ✅ Auto-Rescheduled |
|---|---|
| 10:00 — Reply to client email | 10:00 — Reply to client email |
| 12:30 — Prep meeting deck | 12:30 — Prep meeting deck |
| ~~3:00 — Review PR~~ 🔴 **MISSED** | 4:15 — Review PR 🟢 **re-slotted** |

</div>

---

## 🛠️ Tech Stack

<table>
<tr><td width="140"><b>Client</b></td><td>Flutter + Dart — Riverpod (state), Dio (API client)</td></tr>
<tr><td><b>Backend</b></td><td>NestJS + TypeScript + Node.js — REST APIs, auth, business logic</td></tr>
<tr><td><b>API Docs</b></td><td>OpenAPI / Swagger</td></tr>
<tr><td><b>Database</b></td><td>PostgreSQL + Prisma ORM</td></tr>
<tr><td><b>Cache / Queue</b></td><td>Redis — extraction job queue, rate limiting</td></tr>
<tr><td><b>Object Storage</b></td><td>Amazon S3 — meeting transcripts & documents</td></tr>
<tr><td><b>Auth</b></td><td>JWT (access + refresh) + OAuth 2.0</td></tr>
<tr><td><b>Containerization</b></td><td>Docker</td></tr>
<tr><td><b>Cloud</b></td><td>AWS — ECS/EC2, RDS, ElastiCache, S3, CloudFront, Route 53, IAM</td></tr>
<tr><td><b>CI/CD</b></td><td>GitHub Actions</td></tr>
<tr><td><b>Monitoring</b></td><td>CloudWatch + Sentry</td></tr>
</table>

---

## 🏗️ System Architecture

```mermaid
flowchart TD
    A["📱 Flutter Client"] -- HTTPS / REST --> B["🧠 NestJS API"]
    B --> C["🔐 Auth (JWT / OAuth)"]
    B --> D["📥 /capture/email"]
    B --> E["📥 /capture/meeting"]
    B --> F["✅ /tasks"]
    B --> G["⏰ /schedule"]
    D --> H[("🗄️ PostgreSQL")]
    E --> H
    F --> H
    G --> H
    D -.-> I[("⚡ Redis Queue")]
    E -.-> I
    E --> J[("☁️ Amazon S3")]
    H --> K["🚀 AWS (ECS · RDS · ElastiCache · S3)"]
```

<details>
<summary><b>📊 Sequence: Capture → Schedule flow</b></summary>

```mermaid
sequenceDiagram
    participant U as User (Flutter)
    participant API as NestJS API
    participant Q as Redis Queue
    participant LLM as LLM Extractor
    participant DB as PostgreSQL

    U->>API: POST /capture/email (raw text)
    API->>Q: enqueue extraction job
    Q->>LLM: extract task, deadline, priority
    LLM-->>Q: structured task JSON
    Q->>DB: insert into Task table
    U->>API: POST /schedule
    API->>DB: fetch pending tasks + free slots
    API->>API: run priority/deadline slotting
    API->>DB: update Task.scheduledAt
    API-->>U: Today's Plan
```

</details>

---

## 🗃️ Data Model

```mermaid
erDiagram
    USER ||--o{ TASK : owns
    USER ||--o{ FREESLOT : declares
    TASK {
        string id PK
        string userId FK
        string title
        string source
        datetime deadline
        string priority
        string status
        datetime scheduledAt
    }
    FREESLOT {
        string id PK
        string userId FK
        datetime startTime
        datetime endTime
        boolean isBooked
    }
    USER {
        string id PK
        string email
        string name
    }
```

<details>
<summary><b>View raw Prisma schema</b></summary>

```prisma
model Task {
  id          String    @id @default(uuid())
  userId      String
  title       String
  source      String    // "email" | "meeting" | "manual"
  deadline    DateTime?
  priority    String    // "high" | "medium" | "low"
  status      String    // "pending" | "scheduled" | "done" | "missed"
  scheduledAt DateTime?
  createdAt   DateTime  @default(now())
}

model FreeSlot {
  id        String   @id @default(uuid())
  userId    String
  startTime DateTime
  endTime   DateTime
  isBooked  Boolean  @default(false)
}

model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())
}
```

</details>

---

## 📁 Project Structure

<details>
<summary><b>Expand full directory tree</b></summary>

```
dayzero/
├── apps/
│   ├── client/                 # Flutter application
│   │   └── lib/
│   │       ├── core/
│   │       ├── features/
│   │       │   ├── capture/    # paste-in screens for email / meeting text
│   │       │   ├── today/      # "Today's Plan" view
│   │       │   ├── tasks/      # all-tasks list, filters
│   │       │   └── reschedule/ # "I missed this" action
│   │       ├── shared/
│   │       ├── routing/
│   │       ├── services/
│   │       └── main.dart
│   │
│   └── api/                    # NestJS backend
│       └── src/
│           ├── auth/           # JWT + refresh token flow
│           ├── capture/        # email & meeting extraction endpoints
│           ├── tasks/          # CRUD + status transitions
│           ├── scheduler/      # priority/deadline-based slotting engine
│           ├── users/
│           ├── common/
│           ├── database/       # Prisma module
│           ├── storage/        # S3 integration
│           ├── cache/          # Redis integration
│           ├── jobs/           # background job processors
│           └── main.ts
│
├── prisma/
│   └── schema.prisma
│
├── docker-compose.yml          # local Postgres + Redis
├── .github/workflows/          # CI/CD pipelines
└── README.md
```

</details>

---

## 🔌 API Overview

| Endpoint | Method | Description |
|---|---|---|
| `/auth/register` | `POST` | Create a new user account |
| `/auth/login` | `POST` | Authenticate and receive JWT + refresh token |
| `/capture/email` | `POST` | Submit email text; returns extracted task(s) |
| `/capture/meeting` | `POST` | Submit meeting transcript/notes; returns extracted task(s) |
| `/tasks` | `GET` | List all tasks for the authenticated user (filterable by source/status) |
| `/tasks/:id` | `PATCH` | Update a task's status (e.g. mark as `missed` or `done`) |
| `/schedule` | `POST` | Run/re-run the scheduling engine against pending tasks and free slots |
| `/slots` | `POST` | Declare a free-time block for the day |

> Full request/response contracts are documented via Swagger at `/api/docs` once the backend is running.

---

## 🚀 Getting Started

### Prerequisites

- Node.js 18+
- Flutter SDK 3.x
- Docker & Docker Compose
- PostgreSQL 15+ (or use the provided Docker Compose setup)

<details open>
<summary><b>1️⃣ Clone the repository</b></summary>

```bash
git clone https://github.com/<your-username>/dayzero.git
cd dayzero
```

</details>

<details open>
<summary><b>2️⃣ Start local infrastructure (Postgres + Redis)</b></summary>

```bash
docker compose up -d
```

</details>

<details open>
<summary><b>3️⃣ Set up the backend</b></summary>

```bash
cd apps/api
cp .env.example .env      # fill in DATABASE_URL, REDIS_URL, JWT secrets, S3 credentials
npm install
npx prisma migrate dev
npm run start:dev
```

The API will be available at `http://localhost:3000`, with Swagger docs at `http://localhost:3000/api/docs`.

</details>

<details open>
<summary><b>4️⃣ Set up the Flutter client</b></summary>

```bash
cd apps/client
flutter pub get
flutter run                # or: flutter run -d chrome for web
```

Update the base API URL in `lib/core/config.dart` to point to your running backend.

</details>

---

## 🔑 Environment Variables

<details>
<summary><b>View required <code>.env</code> keys (<code>apps/api/.env</code>)</b></summary>

```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dayzero

# Redis
REDIS_URL=redis://localhost:6379

# Auth
JWT_ACCESS_SECRET=your_access_secret
JWT_REFRESH_SECRET=your_refresh_secret
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d

# AWS S3
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_REGION=ap-south-1
AWS_S3_BUCKET=dayzero-uploads

# LLM Provider
LLM_API_KEY=your_llm_api_key
```

</details>

---

## 🐳 Running with Docker

```bash
docker compose up -d        # Postgres + Redis
docker compose down         # stop and remove containers
```

For a fully containerized backend (API + Postgres + Redis together), build the API image:

```bash
docker build -t dayzero-api ./apps/api
docker run --env-file ./apps/api/.env -p 3000:3000 dayzero-api
```

---

## ☁️ Deployment

<table>
<tr>
<td width="50%" valign="top">

### 🧪 Hackathon prototype (fast path)
- **Backend:** Render / Railway with managed Postgres + Redis add-on
- **Client:** Flutter Web build → Firebase Hosting / Netlify

</td>
<td width="50%" valign="top">

### 🏭 Production path (roadmap)
- Backend containers on **AWS ECS/EC2**
- Managed DB on **AWS RDS** (PostgreSQL)
- Managed cache on **AWS ElastiCache** (Redis)
- File storage on **S3**, served via **CloudFront**
- DNS via **Route 53**, secrets via **Secrets Manager**
- CI/CD: lint → test → build → Docker image → registry → deploy (dev / staging / prod)
- Monitoring via **CloudWatch** + **Sentry**

</td>
</tr>
</table>

---

## 🎯 Hackathon MVP Scope

To keep the Phase 1 build demoable within the hackathon timeframe:

- ✅ Paste-in email/meeting text instead of live Gmail OAuth or audio transcription
- ✅ Backend run locally / on a free-tier host instead of full AWS deployment
- ✅ Manually declared free-time blocks instead of full calendar sync

> **The one feature prioritized for the live demo:** the adaptive rescheduler — marking a task "missed" and watching the scheduler automatically re-slot it. This is what makes DayZero feel like a planner, not a static to-do list.

## 🗺️ Roadmap

- [ ] Live Gmail / Outlook integration via OAuth
- [ ] Audio meeting transcription (Whisper or equivalent)
- [ ] Google/Outlook Calendar sync for real free-slot detection
- [ ] Team/shared task views
- [ ] Mobile push notifications for upcoming and rescheduled tasks
- [ ] Full AWS production deployment (ECS, RDS, ElastiCache, CloudFront)

## 🏆 Prior Work

This project builds on prior hackathon experience, including an **Email Triage Environment** built for the Meta × Scaler × PyTorch OpenEnv Hackathon (FastAPI + Pydantic v2, containerized and deployed to HuggingFace Spaces, passed Phase 1 automated validation) — the email-extraction logic in DayZero's `/capture/email` endpoint builds directly on that work.

## 📄 License

This project was built for hackathon submission purposes. License to be finalized post-submission.

---

<div align="center">

*"Everyone builds a to-do list. DayZero is the layer before it — and the layer after it."*

</div>
