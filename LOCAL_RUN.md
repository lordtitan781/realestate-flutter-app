Local run notes and new features

This repository now includes backend and frontend support for two new features:

1. Investors — Expression of Interest (EOI)
   - Backend: `Eoi` entity, `EoiRepository`, `EoiController`
   - Endpoints:
     - POST `/api/projects/{projectId}/eois` — submit an EOI for a project
     - GET `/api/projects/{projectId}/eois` — list EOIs for a project
   - Frontend: `lib/models/eoi.dart`, `lib/features/project/eoi_form.dart`, and `ApiService` methods

2. Landowner submissions — richer land data
   - Backend: `Land` entity extended with `legalDocuments`, `utilities` (collection), and `reviewStatus`.
   - Endpoints:
     - POST `/api/lands` — submit land (accepts utilities as JSON array)
     - PUT `/api/lands/{id}` — update land
     - PUT `/api/lands/{id}/review` — update review status (admin)
   - Frontend: `lib/models/land.dart` updated (utilities is a list) and `lib/features/land/land_submission_form.dart`

Notes & local run steps
- The backend uses PostgreSQL configured in `backend/src/main/resources/application.properties` — ensure the DB is running and credentials are correct.
- To build/run backend locally (on your machine):

```bash
cd backend
mvn -DskipTests package
# or
mvn spring-boot:run
```

- For Android emulator networking use `10.0.2.2` instead of `localhost` in the Flutter `ApiService.baseUrl`.
- I couldn't run build tools in this environment; please run the above commands locally. If you encounter compile errors, paste the output and I'll fix them.
