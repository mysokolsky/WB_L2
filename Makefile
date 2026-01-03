# Собираем все цели из этого файла в качестве значения переменной ALL_TARGETS
ALL_TARGETS := $(shell grep -E '^[a-zA-Z0-9_-]+:' Makefile | cut -d: -f1 | grep -v '^\.' | sort -u)

# Убираем конфликты названий целей с одноимёнными файлами
.PHONY: $(ALL_TARGETS)

# Определяем последнюю по числу папку для добавления в репу, например L3.21
# LAST_TASK := $(shell ls -d L*.* | sort -V | tail -n1)
LAST_TASK := $(shell ls -d L*.* 2>/dev/null | sort | tail -n 1)

# Первый аргумент вызова make сохраним в переменную PARAM
# Пример: 
# > make Arg1 target1 target2 ...
# Arg1 сохраняем в переменную PARAM:
PARAM := $(firstword $(MAKECMDGOALS))

##############################################################################
#   Ниже идёт блок-условие, который обрабатывает входной параметр PARAM,
#   в зависимосим от его содержания. Если PARAM - одна из целей текущего 
#   файла, то запускается эта цель, если нет, то предполагается, что PARAM
#   содержит название подпапки, в которой требуется запустить проект
#   Например, при вызове из консоли make L1.1, в цель run передастся 
#   значение подпапки L1.1, в которой будет запущен проект
#   Кроме того, из строки вызова так же передаются аргументы для запуска программ
#   Например, вызов make L1.8 <<< "-010011 1 0" будет равносилен вызову в консоли
#   cd L1.8; go run . <<< "-010011 1 0"; cd ..
#
ifeq ($(filter $(PARAM),$(ALL_TARGETS)),) # если PARAM есть в списке целей ALL_TARGETS, то функция возвращает PARAM, иначе возвращает пустоту
ifeq ($(PARAM),) # если PARAM пустой, то выходим из дальнейших условий и выполняем стандартный ход событий
else # если PARAM не пустой (то есть не является одной из целей в этом файле), то..
$(eval .PHONY: $(PARAM)) # realtime (параметр eval) добавляем его к списку названий всех целей для устранения конфликта при запуске на случай наличия одноименного файла
$(eval $(PARAM): ; @$(MAKE) run LAST_TASK=$(PARAM)) # создаём динамическую цель PARAM: и сразу запускаем её (она делает переадресацию на цель run) при этом переопределяя переменную LAST_TASK = PARAM
endif
endif

# Автоматическая цель для запуска проекта в папке LAST_TASK
run: ensure-git init_new_task 
	@DIR="."; \
	if [ -n "$(LAST_TASK)" ] && [ -d "$(LAST_TASK)" ]; then \
		DIR="$(LAST_TASK)"; \
	fi; \
	cd "$$DIR" && { \
		if [ ! -f main.go ]; then \
			echo "package main\n\nfunc main() {\nprintln(123)\n}\n" > main.go; \
		fi; \
		go run .; \
	}



###############################################################################
##                                                                           ##
##                    CОЗДАНИЕ НОВОГО РЕПОЗИТОРИЯ WB_L..                     ##
##                                                                           ##
###############################################################################

# Считываем сокращённое имя папки проекта для добавления к пути репозитория. Например, L3
PROJ_DIR := $(notdir $(CURDIR))

# Имя репозитория, например WB_L3
REPO_NAME := WB_$(PROJ_DIR)

# Токен GitHub (лежит уровнем выше и не вставляется в репу для сохранения приватности репы)
ifeq ($(wildcard ../github_privacy/gh_tok.en),)
GITHUB_TOKEN :=
else
GITHUB_TOKEN := $(shell cat ../github_privacy/gh_tok.en)
endif

# Проверка существования токена
check-token:
	@if [ -z "$(GITHUB_TOKEN)" ]; then \
		echo "❌ GITHUB_TOKEN не найден"; \
		exit 1; \
	fi


# URL API GitHub
GITHUB_API := https://api.github.com/user/repos

# URL репозитория
GIT_URL := git@github.com:mysokolsky/$(REPO_NAME).git






# # Создаём репозиторий, если его ещё нет
# create-repo:
# 	@if git ls-remote $(GIT_URL) >/dev/null 2>&1; then \
# 		echo "Репозиторий $(REPO_NAME) уже существует"; \
# 	else \
# 		echo "Создаём репозиторий $(REPO_NAME)"; \
# 		curl -s -H "Authorization: token $(GITHUB_TOKEN)" \
# 		     -H "Accept: application/vnd.github.v3+json" \
# 		     $(GITHUB_API) \
# 		     -d '{"name":"$(REPO_NAME)","private":false,"auto_init":true}'; \
# 	fi

create-repo: check-token
	@if curl -s -o /dev/null -w "%{http_code}" \
		-H "Authorization: token $(GITHUB_TOKEN)" \
		https://api.github.com/repos/mysokolsky/$(REPO_NAME) | \
		grep -q 404; then \
		echo "Создаём репозиторий $(REPO_NAME)"; \
		curl -s \
			-H "Authorization: token $(GITHUB_TOKEN)" \
		    -H "Accept: application/vnd.github.v3+json" \
		    $(GITHUB_API) \
		    -d '{"name":"$(REPO_NAME)","private":false,"auto_init":true,"default_branch":"develop"}'; \
	fi




ensure-git: ensure-local-git create-repo ensure-origin

ensure-local-git:
	@if [ ! -d .git ]; then \
		echo "Инициализируем локальный git-репозиторий для разработки (ветка develop)"; \
		git init -b develop; \
		echo "Локальный Git инициализирован с веткой develop"; \
	fi

ensure-origin:
	@if ! git remote | grep -q origin; then \
		echo "Добавляем remote origin"; \
		git remote add origin $(GIT_URL); \
	fi


###############################################################################
##                                                                           ##
##                    ЗАЛИВКА ПОСЛЕДНИХ ИЗМЕНЕНИЙ В РЕПУ                     ##
##                                                                           ##
###############################################################################

# Определяем ветку для автоматического пуша
# GITBRANCH:=$(shell git rev-parse --abbrev-ref HEAD >/dev/null 2>&1)
GITBRANCH := $(shell git branch --show-current)

# Если вдруг git старый (до 2.22) и ветка пуста, используем fallback
ifeq ($(GITBRANCH),)
    GITBRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "develop")
endif

# Получаем данные, настроен ли remote для текущей ветки
# Если HAS_UPSTREAM пуст, значит upstream не настроен
# настроенный upstream позволит писать короткие команды git push и git pull без указания origin
HAS_UPSTREAM := $(shell git config --get branch.$(GITBRANCH).remote)

# Есть ли хотя бы один коммит
HAS_COMMITS := $(shell git rev-parse --verify HEAD >/dev/null 2>&1 && echo yes)


init_commit:
	@git rev-parse --verify HEAD >/dev/null 2>&1 || { \
		echo "Коммитов нет — создаём initial commit"; \
		git add . && git commit -m "init"; \
	}

# Настройка upstream по необходимости
set_upstream:
ifeq ($(HAS_UPSTREAM),)
	@echo "Upstream не настроен для ветки $(GITBRANCH). Настраиваем..."
	@$(MAKE) init_commit
	@git push --set-upstream origin $(GITBRANCH)
endif

# Дальше цели для работы с гитом
add:
	@if [ -n "$(LAST_TASK)" ] && [ -e "$(LAST_TASK)" ]; then \
		git add "$(LAST_TASK)"; \
	fi; sleep 1
	@for f in *; do \
		if [ -f "$$f" ]; then \
			git add "$$f" 2>/dev/null || true; \
		fi; \
	done

commit:
	@git commit -m "=== $(LAST_TASK) == $(GITBRANCH) === $(shell date +'ДАТА %d-%m-%y === ВРЕМЯ %H:%M:%S') ====="; sleep 1

push: set_upstream add
	@if git diff --cached --quiet; then \
		echo "Нет изменений для сохранения."; \
	else \
		$(MAKE) commit; \
		git push; \
	fi

push_all: set_upstream
	@git add .
	@$(MAKE) commit
	@git push

# автоматическая загрузка с гит-репозитория на текущую машину
pull:
	git stash
	git pull

###############################################################################
##                                                                           ##
##                              СЛУЖЕБНЫЕ ЦЕЛИ                               ##
##                                                                           ##
###############################################################################

# Сохранить токен для приватного доступа к гитхабу
gh_token_save:
	git config --global credential.helper osxkeychain

# Убрать предупрежение о включении игногируемых файлов в репу
skip_attention:
	git config advice.addIgnoredFile false

# инициализировать голанг-проект в папке последнего задания
init_new_task:
	@if [ ! -f "go.mod" ]; then \
		echo "go.mod не найден, инициализируем новый проект..."; \
		echo; \
		go mod init github.com/mysokolsky/$(REPO_NAME) > /dev/null 2>&1; \
		go mod tidy  > /dev/null 2>&1; \
		$(MAKE) push; \
	fi