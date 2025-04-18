# Votely

**Votely** is a modern, real-time voting application built for simplicity and style. It features a responsive Flutter web frontend with a dark, elegant UI and a robust Python backend using UDP/TCP servers for vote processing. Users can add candidates, cast votes, and view live results with a winner announcement. Designed as a college project, Votely showcases seamless integration of frontend and backend technologies — perfect for small-scale elections or demos.

---

## 🚀 Features

- **Add Candidates**: Easily register new candidates via a clean form.
- **Cast Votes**: Vote for candidates with a single click, with real-time updates.
- **Live Results**: View vote counts, percentages, and the leading candidate in a sleek dashboard.
- **Responsive Design**: Works on mobile and desktop with a shadcn/ui-inspired aesthetic (dark theme, gold/red accents).
- **Shutdown & Exit**: Gracefully close the server and app, displaying final results.
- **Persistent Storage**: Votes are saved to `totalvotes.json` for reliability.

---

## 🛠️ Tech Stack

- **Frontend**: Flutter (web), Dart, HTTP client for API communication.
- **Backend**: Python, Flask (`relay_server.py`), UDP/TCP servers (`server.py`).
- **Deployment**: GitHub Pages for the frontend, with GitHub Actions for CI/CD.
- **Storage**: JSON file (`totalvotes.json`) for vote persistence.

---

## 📦 Prerequisites

- **Flutter**: Version 3.24.3 or later ([installation guide](https://docs.flutter.dev/get-started/install)).
- **Python**: Version 3.8+ with `flask` and `flask-cors` packages.
- **Git**: For cloning and pushing to GitHub.
- **GitHub Account**: For hosting and deployment.

---

## ⚙️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/votely.git
cd votely
```

### 2. Set Up the Frontend (Flutter)

```bash
flutter pub get
flutter run -d chrome
```

Opens Votely in your browser at `http://localhost:<port>`.

### 3. Set Up the Backend (Python)

```bash
pip install flask flask-cors
python server.py        # Starts the UDP/TCP server
python relay_server.py  # Starts the Flask relay server
```

- UDP: `0.0.0.0:9999`
- TCP: `0.0.0.0:9998`
- Flask: `http://192.168.29.80:5000` (update IP in `main.dart` if needed)

---

### 4. Using ngrok (Optional)

Expose Flask server for remote access:

```bash
ngrok http 5000
```

Update `serverUrl` in `main.dart` with your ngrok URL, e.g., `https://abc123.ngrok.io`.

Rebuild app:

```bash
flutter build web --release
```

---

## 📲 Usage

### ✅ Add Candidates

- Go to the “Add Candidate” tab.
- Enter names like `bro`, `yo`, `sub` and click **Submit**.

### 🗳️ Cast Votes

- In the “Vote” tab, click a candidate’s card.
- A confirmation SnackBar appears (e.g., “Voted for bro!”).

### 📊 View Results

- Navigate to the “Results” tab.
- Live vote counts and percentages shown.
- Leading candidate highlighted.

### 📴 Close Server

- In the “Vote” tab, click **Close Server**.
- Redirects to final results with winner.

### ❌ Exit App

- In the “Results” tab (post-shutdown), click **Exit App**.
- Confirms via dialog and closes browser tab.

---

## 🚀 Deployment to GitHub Pages

### GitHub Actions Workflow

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Flutter Web to GitHub Pages

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.3'
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Build Flutter web
        run: flutter build web --release

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: build/web
          publish_branch: gh-pages
          keep_files: false
          user_name: 'github-actions[bot]'
          user_email: 'github-actions[bot]@users.noreply.github.com'
```

### Commit and Push

```bash
git add .github/workflows/deploy.yml
git commit -m "Add GitHub Actions workflow"
git push origin main
```

---

### Enable GitHub Pages

- Go to **Settings > Pages**.
- Set **Source** to `gh-pages` branch.
- Set folder to `/ (root)` and **Save**.

### Access the App

After ~2–3 minutes, visit:

```
https://<your-username>.github.io/votely/
```

---

## 🌐 Backend for Deployment

GitHub Pages is static. You must run the backend separately.

- **Local**: Run backend with ngrok and update `main.dart`.
- **Hosted**: Deploy `relay_server.py` to Render/Heroku.
- **Mock**: For demo purposes, mock `fetchResults`:

```dart
Future<Map<String, int>> fetchResults() async {
  return {'bro': 1, 'yo': 1, 'sub': 2};
}
```

---

## 🛠️ Troubleshooting Deployment

### Workflow Not Found

- Ensure `.github/workflows/deploy.yml` exists (case-sensitive).
- Check default branch (`main`, `master`, etc.).
- Validate YAML syntax at [yamllint.com](https://yamllint.com/).
- Enable all actions in **Settings > Actions > General**.

### Build Fails

- Check GitHub Actions logs.
- Ensure Flutter version matches.
- Add `flutter doctor` to workflow for diagnostics:

```yaml
- name: Run flutter doctor
  run: flutter doctor -v
```

### Page Blank or 404

- Check `gh-pages` branch for `build/web` files.
- Wait 1–2 mins after deployment.
- Open DevTools console (F12) for errors.

### Backend Errors

- Use public URL (ngrok/Render) in `main.dart`.
- Ensure `relay_server.py` allows CORS:

```python
CORS(app, resources={r"/*": {"origins": "*"}})
```

---

## 🖼️ Screenshots

> _(Add screenshots of the Vote, Results, and Add Candidate pages using Snipping Tool or Chrome DevTools)_

---

## 🤝 Contributing

1. Fork the repo.
2. Create a branch: `git checkout -b feature-name`.
3. Commit changes: `git commit -m "Add feature"`.
4. Push: `git push origin feature-name`.
5. Open a pull request.

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.

---

## 📬 Contact

- For issues or suggestions, open an issue on GitHub.
- Contact: `<your-email>`

---

**Built for a college project by Subroto Banerjee. Powered by Flutter and Python.**
```