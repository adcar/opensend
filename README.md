# OpenSend

An open-source alternative to DocuSend and Firefox Send. Share files securely with granular permissions.

## Features

- **Drag & Drop Upload**: Upload files up to 10MB with a beautiful interface
- **Granular Permissions**: Control access with:
  - Email requirement for viewing
  - Passcode protection
  - Expiration dates
  - Download restrictions
- **AI-Powered Insights**: GPT-4o analyzes your documents to generate:
  - Smart titles
  - Summaries
  - Key topics
  - Document classification
- **Analytics**: Track views and downloads for each share link

## Tech Stack

- **Backend**: Ruby on Rails 7.1
- **Database**: PostgreSQL (Docker for local, Vercel Postgres for production)
- **Storage**: Local disk (development) / Vercel Blob (production)
- **AI**: OpenAI GPT-4o for document analysis
- **Frontend**: Vanilla JS with Turbo & Stimulus

## Local Development

### Prerequisites

- Ruby 3.3.0
- Docker & Docker Compose
- Bundler

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/opensend.git
   cd opensend
   ```

2. Create environment file:
   ```bash
   cp .env.example .env
   ```

3. Add your OpenAI API key to `.env` (optional, for AI features):
   ```
   OPENAI_API_KEY=your_key_here
   ```

4. Run setup:
   ```bash
   chmod +x bin/*
   bin/setup
   ```

5. Start the server:
   ```bash
   bin/dev
   ```

6. Visit http://localhost:5000

## Deployment to Vercel

1. Install Vercel CLI:
   ```bash
   npm i -g vercel
   ```

2. Set up Vercel Postgres:
   - Create a Postgres database in Vercel Dashboard
   - Add the `DATABASE_URL` environment variable

3. Set up Vercel Blob Storage:
   - Create a Blob store in Vercel Dashboard
   - Add `BLOB_READ_WRITE_TOKEN` environment variable

4. Add environment variables:
   ```bash
   vercel env add SECRET_KEY_BASE
   vercel env add OPENAI_API_KEY
   vercel env add JWT_SECRET
   ```

5. Deploy:
   ```bash
   vercel
   ```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection string | Yes |
| `SECRET_KEY_BASE` | Rails secret key | Yes (production) |
| `OPENAI_API_KEY` | OpenAI API key for GPT-4o | No |
| `BLOB_READ_WRITE_TOKEN` | Vercel Blob token | No (uses local storage) |
| `JWT_SECRET` | Secret for JWT tokens | Yes (production) |

## License

MIT License - see LICENSE file for details.

