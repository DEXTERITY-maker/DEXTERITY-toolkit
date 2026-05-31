# Makefile для DEXTERITY v4.0

NAME = dexterity
VERSION = 4.0
BINARY = dexter.sh
INSTALL_DIR = /usr/local/bin

# Цель по умолчанию: показать помощь
all: help

# Цель: установка скрипта локально (для разработки)
install-local:
	@echo "📦 Устанавливаю DEXTERITY локально..."
	@install -D $(BINARY) $(INSTALL_DIR)/$(NAME)
	@echo "✅ Установка завершена. Теперь вы можете запустить программу командой: $(NAME)"

# Цель: сборка deb-пакета
deb:
	@echo "📦 Собираю deb-пакет для DEXTERITY..."
	@mkdir -p deb_package/usr/local/bin
	@install -D $(BINARY) deb_package/usr/local/bin/$(NAME)
	@mkdir -p deb_package/DEBIAN
	@echo "Package: $(NAME)" > deb_package/DEBIAN/control
	@echo "Version: $(VERSION)" >> deb_package/DEBIAN/control
	@echo "Section: base" >> deb_package/DEBIAN/control
	@echo "Priority: optional" >> deb_package/DEBIAN/control
	@echo "Architecture: all" >> deb_package/DEBIAN/control
	@echo "Maintainer: DEXTERITY-maker <Kirillfapsy@gmail.com>" >> deb_package/DEBIAN/control
	@echo "Description: DEXTERITY v$(VERSION) - modern tool for UserLAnd" >> deb_package/DEBIAN/control
	@dpkg-deb --build deb_package
	@mv deb_package.deb $(NAME)-$(VERSION).deb
	@rm -rf deb_package
	@echo "✅ Deb-пакет создан: $(NAME)-$(VERSION).deb"

# Цель: публикация новой версии на GitHub
release: deb
	@echo "🚀 Публикую новую версию на GitHub..."
	@git add .
	@git commit -m "Release DEXTERITY v$(VERSION)" || true
	@git push origin main
	@echo "✅ Новая версия опубликована!"

# Цель: помощь
help:
	@echo "Доступные команды:"
	@echo "  make install-local - Установить DEXTERITY локально"
	@echo "  make deb           - Собрать deb-пакет"
	@echo "  make release       - Опубликовать новую версию на GitHub"
	@echo "  make help          - Показать эту справку"

.PHONY: all install-local deb release help
