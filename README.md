# Инфраструктура как код

[![hexlet-check](https://github.com/Absaidov/devops-engineer-from-scratch-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/Absaidov/devops-engineer-from-scratch-project-77/actions)

Автоматическое развёртывание отказоустойчивого Redmine в Yandex Cloud с
помощью Terraform и Ansible.

Учебный проект Хекслета: https://ru.hexlet.io/programs/devops-engineer-from-scratch
Как это должно работать: https://asciinema.org/a/aeg7afREm5TJHn9PT0S465lEa

## Стек

- Terraform 1.6.3+
- Ansible Core
- Yandex Cloud
- Yandex Object Storage для удалённого Terraform State
- Redmine 6.1.5
- Managed Service for PostgreSQL 17
- Application Load Balancer и Certificate Manager

## Архитектура

Terraform создаёт:

- сеть и две подсети в `ru-central1-d` и `ru-central1-e`;
- две ВМ Ubuntu 24.04 с Redmine в Docker;
- приватный кластер PostgreSQL без публичного IP;
- отдельные группы безопасности для балансировщика, ВМ и базы данных;
- L7-балансировщик с постоянным публичным IP;
- HTTP-редирект на HTTPS и TLS-терминацию;
- публичную DNS-зону `uit14.ru` и управляемый сертификат Let's Encrypt.

База данных принимает подключения только от группы безопасности веб-серверов,
а порт Redmine `3000` доступен только балансировщику.

## Требования

- Terraform 1.6.3 или новее;
- Ansible Core;
- Yandex Cloud CLI;
- `make`, `openssl` и SSH-ключ `~/.ssh/id_ed25519.pub`;
- сервисный аккаунт с ролями `storage.editor`, `vpc.admin`, `compute.editor`,
  `alb.editor`, `managed-postgresql.editor`, `dns.editor` и
  `certificate-manager.editor`, `vpc.publicAdmin` и
  `certificate-manager.certificates.downloader` только в каталоге проекта.

Роль `vpc.publicAdmin` нужна для назначения публичного IP L7-балансировщику,
а `certificate-manager.certificates.downloader` — для подключения TLS-сертификата
к HTTPS-listener.

## Установка

```bash
git clone https://github.com/Absaidov/devops-engineer-from-scratch-project-77.git
cd devops-engineer-from-scratch-project-77
```

Убедитесь, что установлены Terraform и Ansible:

```bash
terraform version
ansible --version
```

### Подготовка секретов Terraform

Зашифрованный файл `ansible/group_vars/all/vault.yml` хранится в репозитории.
Чтобы создать его в новой копии проекта, используйте:

```bash
EDITOR=nano make vault-create
```

Для изменения существующего Vault:

```bash
EDITOR=nano make vault-edit
```

Структура переменных приведена в
`ansible/group_vars/all/vault.yml.example`. Пароль базы данных и общий секрет
двух экземпляров Redmine можно сгенерировать локально:

```bash
openssl rand -hex 24
openssl rand -hex 64
```

Сохраните результаты соответственно в `vault_database_password` и
`vault_redmine_secret_key_base`. Не добавляйте открытые значения в Git.

Путь к публичному SSH-ключу и разрешённая для SSH сеть находятся в
`ansible/group_vars/all/vars.yml`. При смене внешнего IP обновите
`ssh_allowed_cidrs`.

Сгенерируйте локальные файлы Terraform и подключите удалённый backend:

```bash
make setup
```

Команда создаёт файлы `terraform/authorized_key.json`,
`terraform/secrets.auto.tfvars` и `terraform/backend.hcl` с правами `0600`.
Они содержат локальные параметры доступа, игнорируются Git и не должны
добавляться в репозиторий.

### Инициализация без доступа к облаку

Для CI и проверки конфигурации в чистом окружении backend можно отключить:

```bash
make terraform-init-local
```

Команда выполняет `terraform init -backend=false`: ей не нужны ключи или
доступ к Yandex Cloud. Все используемые провайдеры объявлены в
`required_providers` с `source` и ограничением версии.

## Использование

Проверка форматирования и конфигурации:

```bash
make check
```

Просмотр плана и создание инфраструктуры:

```bash
make plan
make apply
```

Просмотр адресов созданных ресурсов:

```bash
make output
```

После выпуска сертификата приложение будет доступно по адресу
[https://uit14.ru](https://uit14.ru). Выпуск сертификата Let's Encrypt и
появление здоровых бэкендов могут занять несколько минут.

Удаление всей созданной Terraform инфраструктуры:

```bash
make destroy
```

Команда требует явного подтверждения. Удалённый state хранится в закрытом
Object Storage по ключу `project-77/terraform.tfstate`; локальные state-файлы
и каталог `.terraform/` игнорируются Git.

---

<details>
<summary>Автоматические тесты Хекслета</summary>

Тесты запускаются на каждый коммит. За запуск отвечает файл `.github/workflows/hexlet-check.yml` — не удаляйте и не переименовывайте ни его, ни репозиторий.

</details>

## О Хекслете

[Хекслет](https://ru.hexlet.io/) — школа программирования: авторские программы обучения с практикой, поддержкой наставников и реальными проектами, которые остаются в резюме. Этот репозиторий — один из таких проектов.
