# Wymagania projektu dyplomowego DevOps

## Obowiązkowe elementy
- Aplikacja z publicznego repozytorium lub własna prosta aplikacja.
- Automatyczne tworzenie infrastruktury jako kod (IaC).
- Wdrożenie infrastruktury od zera niewielką liczbą komend.
- Idempotentność: ponowne uruchomienie konfiguracji nie powoduje zbędnych zmian.
- Monitoring infrastruktury i aplikacji.
- Dokumentacja zawartości repozytorium, budowania i wdrażania.

## CI/CD
- Push do dowolnej gałęzi uruchamia budowanie aplikacji i publikację artefaktu w rejestrze.
- Push do main dodatkowo uruchamia automatyczne wdrożenie.
- Powiadomienia o wyniku budowania i wdrożenia trafiają na wybrany kanał komunikacji.

## Opcjonalne rozszerzenia
- TLS, wiele replik i load balancer.
- Docker i Kubernetes.
- Dodatkowe testy.
- Pełna automatyzacja konfiguracji CI/CD i monitoringu.
- Centralne zbieranie logów.
- Generowanie dokumentacji kodu.

## Obrona
- Wprowadzenie: 3–5 minut.
- Demonstracja od commita do wdrożenia: 10–12 minut.
- Pytania i dyskusja: 5–7 minut.

Dokument stanowi skrót załącznika „Wymagania Projektu Dyplomowego.md”.
