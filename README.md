# Flutter Excel Uploader

A Flutter application that reads developer records from a local Excel file,
posts each record to a REST API, writes the response back into the Excel sheet,
and exports the updated file — all from a clean mobile UI.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| Networking | http |
| Excel Handling | excel package |
| File System | path_provider |
| File Sharing | share_plus, open_filex |

---

## Architecture

- **Model** — `DeveloperModel` with `toJson()` for API serialization
- **Service** — `saveDevelopersToExcel()` — creates and writes updated Excel file
- **Screen** — `ExcelViewerPage` — loads Excel, renders list, handles POST per record

---

## How It Works

1. App loads developer records from a bundled `.xlsx` asset on launch
2. If an updated file exists in device storage, that is loaded instead
3. Each record displays ID, name, email, and message in a card
4. Tapping **Post** sends the record to the API via HTTP POST
5. API response is written back to the record and saved into a new Excel file
6. The updated Excel file can be opened or shared via the FAB button

---

## Features

- Excel parsing — reads structured data from `.xlsx` on launch
- Per-record API posting with live response feedback
- Writes API response back into Excel — exports updated file
- Snackbar feedback on post success or failure
- Share or open the updated Excel via the system share sheet

---

## API

Uses `jsonplaceholder.typicode.com/posts` as a demo endpoint.
Easily replaceable with any real REST API.

---

## Setup
```bash
git clone https://github.com/Rumaisa19/flutter-excel-uploader.git
cd flutter-excel-uploader
flutter pub get
flutter run
```

---

## Developer

**Rumaisa Mushtaq** — Flutter Developer
- GitHub: [Rumaisa19](https://github.com/Rumaisa19)
- LinkedIn: [rumaisamushtaq](https://linkedin.com/in/rumaisamushtaq)
```
