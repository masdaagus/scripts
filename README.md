# Flutter Shortcut Scripts

Repository ini berisi dua skrip bantu (`domain.sh` dan `infrastructure.sh`) untuk mempercepat setup atau pengelolaan proyek Flutter Anda.

## Cara Mengaktifkan Shortcut di Terminal

1. **Clone atau download repository ini.**

   ```bash
   git clone https://github.com/username/flutter-shortcuts.git
   ```
2. **Beri permission agar script bisa dieksekusi:**
  ```bash
  chmod +x domain.sh
  chmod +x infrastructure.sh
 ```


3. **Tambahkan ke PATH atau buat alias di shell Anda.:**
    Tambahkan baris berikut di file ~/.bashrc, ~/.zshrc, atau ~/.profile:
    ```bash
    export PATH="$PATH:/path/ke/folder/flutter-shortcuts"
    alias domain="bash /path/ke/folder/flutter-shortcuts/domain.sh"
    alias infra="bash /path/ke/folder/flutter-shortcuts/infrastructure.sh"
    source ~/.bashrc
    # atau
    source ~/.zshrc
    ```
