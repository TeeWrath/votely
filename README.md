<p align="center">
   <div align="center">

[![Welcome to Votely](https://img.shields.io/badge/Hello,Programmer!-Welcome-blue.svg?style=flat&logo=github)](https://github.com/TeeWrath/votely)
[![Open Source Love](https://badges.frapsoft.com/os/v2/open-source.svg?v=103)](https://github.com/TeeWrath/votely)
![Stars](https://img.shields.io/github/stars/TeeWrath/votely?style=flat&logo=github)
![Forks](https://img.shields.io/github/forks/TeeWrath/votely?style=flat&logo=github)

</div>
<div align="center">
  <a href="https://github.com/TeeWrath/votely">
  <img src="assets/votely-logo.png" alt="Votely logo" height="300" />
     </a>
</div>
<h2 align="center">Votely</h2>
<p align="center"> A modern, real-time voting app built for simplicity and style. </p>
<br />

[Votely](https://github.com/TeeWrath/votely) is an open-source voting application designed for small-scale elections or demos. With a responsive Flutter web frontend and a robust Python backend, Votely offers a seamless experience for adding candidates, casting votes, and viewing live results. Built as a college project, it combines elegant design with reliable vote processing.

---

[![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/TeeWrath/votely?logo=github)](https://github.com/TeeWrath/votely) 
[![GitHub commit activity](https://img.shields.io/github/commit-activity/m/TeeWrath/votely?color=blueviolet&logo=github)](https://github.com/TeeWrath/votely/commits/) 
[![GitHub repo size](https://img.shields.io/github/repo-size/TeeWrath/votely?logo=github)](https://github.com/TeeWrath/votely)

## ✨ Features  

- 🗳️ **Add Candidates** – Register candidates via a clean, user-friendly form.  
- ✅ **Cast Votes** – Vote with a single click and see real-time updates.  
- 📊 **Live Results** – View vote counts, percentages, and the leading candidate.  
- 📱 **Responsive Design** – Works seamlessly on mobile and desktop with a dark, elegant UI.  
- 💾 **Persistent Storage** – Votes saved to `totalvotes.json` for reliability.  
- 🔌 **Shutdown & Exit** – Gracefully close the server and display final results.  

---

## 🛠️ Tech Stack  

| Technology | Purpose |
|------------|---------|
| **Flutter** | Web frontend (Dart) |
| **Python** | Backend with Flask and UDP/TCP servers |
| **JSON** | Persistent vote storage |
| **GitHub Pages** | Static frontend hosting |
| **GitHub Actions** | CI/CD pipeline |

---

## 🚀 Setup & Installation  

### Prerequisites  
- Flutter SDK (v3.24.3 or later)  
- Python (v3.8+) with `flask` and `flask-cors`  
- Git installed  
- GitHub account for hosting  

### Installation Steps  
```bash
# Clone the repository
git clone https://github.com/TeeWrath/votely.git
cd votely

# Set up frontend (Flutter)
flutter pub get
flutter run -d chrome

# Set up backend (Python)
pip install flask flask-cors
python server.py        # Starts UDP/TCP server
python relay_server.py  # Starts Flask relay server
```
---

## 📲 Usage  

- **Add Candidates**: Go to the “Add Candidate” tab, enter names, and submit.  
- **Cast Votes**: In the “Vote” tab, click a candidate’s card to vote.  
- **View Results**: Check live vote counts and the leader in the “Results” tab.  
- **Close Server**: Use the “Close Server” button in the “Vote” tab to shut down and see final results.  
- **Exit App**: In the “Results” tab, click “Exit App” to close the browser tab.  

---

## 🤝 Contributing  

1. Fork the repository.  
2. Create a branch: `git checkout -b feature-name`.  
3. Commit changes: `git commit -m "Add feature"`.  
4. Push: `git push origin feature-name`.  
5. Open a pull request.  

---

## 📜 License  

This project is licensed under the **MIT License** – see the [`LICENSE`](LICENSE) file for details.  

---

Made with ❤️ by Subroto Banerjee