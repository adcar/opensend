# OpenSend

An open-source alternative to Firefox Send. Share files securely with granular permissions.

## Features

- **Drag & Drop Upload**: Upload files up to 10MB with a beautiful interface
- **Granular Permissions**: Control access with:
  - Passcode protection
  - Expiration dates (max 30 days)
  - Download restrictions
  - Country-based geo-blocking
- **File Previews**: View files directly in browser when downloads are disabled
  - PDFs, images, videos, audio
  - Code files with syntax highlighting
  - DOCX and XLSX with client-side rendering
  - CSV/TSV spreadsheets
- **Analytics**: Track views and downloads for each share link

## Tech Stack

- **Backend**: Ruby on Rails 7.1
- **Database**: PostgreSQL
- **Frontend**: Vanilla JS with Turbo & Stimulus
- **Styling**: Custom CSS with Poppins font

## Deploy to Railway

### One-Click Deploy

1. Fork this repository to your GitHub account

2. Go to [railway.app](https://railway.app) and sign in with GitHub

3. Click **New Project** → **Deploy from GitHub repo** → Select your fork

4. Add a PostgreSQL database:
   - Click **+ New** → **Database** → **Add PostgreSQL**
   - Railway automatically connects it via `DATABASE_URL`

5. Add environment variables to your web service:
   | Variable | Value |
   |----------|-------|
   | `RAILS_ENV` | `production` |
   | `RAILS_SERVE_STATIC_FILES` | `true` |
   | `RAILS_LOG_TO_STDOUT` | `true` |
   | `SECRET_KEY_BASE` | Generate with `rails secret` |

6. Set the **Start Command** in Settings → Deploy:
   ```
   sh -c 'bundle exec rails db:prepare && exec bundle exec puma -C config/puma.rb'
   ```

7. Deploy! Railway will build and deploy your app automatically.

### Manual Configuration

If Railway doesn't auto-detect the Dockerfile:
1. Go to your service **Settings** → **Build**
2. Set **Builder** to `Dockerfile`
3. Set **Dockerfile Path** to `Dockerfile`

## Local Development

### Prerequisites

- Ruby 3.3+
- Docker & Docker Compose
- Bundler

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/adcar/opensend.git
   cd opensend
   ```

2. Start PostgreSQL:
   ```bash
   docker-compose up -d
   ```

3. Install dependencies and setup database:
   ```bash
   bundle install
   bin/rails db:prepare
   ```

4. Start the server:
   ```bash
   bin/rails server -p 5000
   ```

5. Visit http://localhost:5000

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection string | Yes |
| `SECRET_KEY_BASE` | Rails secret key (generate with `rails secret`) | Yes (production) |
| `RAILS_ENV` | Environment (`production` or `development`) | Yes (production) |
| `RAILS_SERVE_STATIC_FILES` | Serve static assets | Yes (production) |
| `RAILS_LOG_TO_STDOUT` | Log to stdout | Yes (production) |

## License

MIT License - see the [LICENSE](LICENSE) file for details.
