# Инфраструктура как код

[![hexlet-check](https://github.com/Absaidov/devops-engineer-from-scratch-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/Absaidov/devops-engineer-from-scratch-project-77/actions)

Автоматизация создания инфраструктуры проекта через Terraform и Ansible

Учебный проект Хекслета: https://ru.hexlet.io/programs/devops-engineer-from-scratch
Как это должно работать: https://asciinema.org/a/aeg7afREm5TJHn9PT0S465lEa

## Стек

- Terraform 1.6.3+
- Ansible Core
- Yandex Cloud
- Yandex Object Storage для удалённого Terraform State

## Установка

<!-- Опишите установку: клонирование, зависимости, переменные окружения -->

```bash
git clone https://github.com/Absaidov/devops-engineer-from-scratch-project-77.git
cd devops-engineer-from-scratch-project-77
```

Убедитесь, что установлены Terraform и Ansible:

```bash
terraform version
ansible --version
```

## Использование

### Подготовка секретов Terraform

Создайте зашифрованный файл Ansible Vault:

```bash
EDITOR=nano make vault-create
```

Добавьте в редактор переменные по образцу из
`ansible/group_vars/all/vault.yml.example`. В файле должны находиться
авторизованный JSON-ключ сервисного аккаунта в формате Base64 и статический
ключ Object Storage для удалённого Terraform State. Base64 позволяет хранить
многострочный JSON одной строкой; защиту значений обеспечивает шифрование
Ansible Vault. Несекретные идентификаторы облака, нового каталога `project-77`
и имя бакета находятся в
`ansible/group_vars/all/vars.yml`.

Для последующего изменения зашифрованных значений используйте:

```bash
EDITOR=nano make vault-edit
```

Сгенерируйте локальные файлы Terraform из Vault:

```bash
make secrets
```

Команда создаёт файлы `terraform/authorized_key.json`,
`terraform/secrets.auto.tfvars` и `terraform/backend.hcl` с правами `0600`.
Они содержат локальные параметры доступа, игнорируются Git и не должны
добавляться в репозиторий.

### Инициализация Terraform

После создания закрытого бакета Object Storage и заполнения Vault выполните:

```bash
make terraform-init
make terraform-fmt
make terraform-validate
```

Terraform хранит state в Object Storage по ключу
`project-77/terraform.tfstate`. Локальные файлы state и каталог `.terraform/`
игнорируются Git.

---

<details>
<summary>Автоматические тесты Хекслета</summary>

Тесты запускаются на каждый коммит. За запуск отвечает файл `.github/workflows/hexlet-check.yml` — не удаляйте и не переименовывайте ни его, ни репозиторий.

</details>

## О Хекслете

[Хекслет](https://ru.hexlet.io/) — школа программирования: авторские программы обучения с практикой, поддержкой наставников и реальными проектами, которые остаются в резюме. Этот репозиторий — один из таких проектов.
