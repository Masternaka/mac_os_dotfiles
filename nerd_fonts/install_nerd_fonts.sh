#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

OS="$(uname -s)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Installation des Nerd Fonts (macOS)${NC}"
echo -e "${BLUE}========================================${NC}\n"
echo -e "${BLUE}Système détecté: ${OS}${NC}\n"

if [[ "$OS" != "Darwin" ]]; then
  echo -e "${RED}❌ Ce script est compatible macOS uniquement.${NC}"
  echo -e "${YELLOW}Astuce:${NC} sur Linux, utilisez le script GitHub dédié.\n"
  exit 1
fi

ensure_brew() {
  if command -v brew &> /dev/null; then
    echo -e "${GREEN}✓ Homebrew détecté${NC}\n"
    return 0
  fi

  echo -e "${YELLOW}Homebrew n'est pas installé.${NC}"
  echo -e "${BLUE}Installation de Homebrew...${NC}\n"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ "$(uname -m)" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  if command -v brew &> /dev/null; then
    echo -e "${GREEN}✓ Homebrew installé avec succès${NC}\n"
  else
    echo -e "${RED}❌ Erreur lors de l'installation de Homebrew${NC}"
    exit 1
  fi
}

ensure_brew

echo -e "${BLUE}Ajout du tap homebrew/cask-fonts...${NC}"
brew tap homebrew/cask-fonts

fonts=(
  "font-jetbrains-mono-nerd-font"
  "font-caskaydia-mono-nerd-font"
  "font-fira-code-nerd-font"
  "font-meslo-lg-nerd-font"
)

for font in "${fonts[@]}"; do
  echo -e "\n${BLUE}Installation de ${font}...${NC}"
  if brew install --cask "$font"; then
    echo -e "${GREEN}✓ ${font} installé avec succès${NC}"
  else
    echo -e "${RED}❌ Erreur lors de l'installation de ${font}${NC}"
  fi
done

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Installation terminée!${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo -e "Les polices sont maintenant disponibles dans vos applications."
echo -e "Vous devrez peut-être redémarrer certaines applications pour voir les nouvelles polices.\n"
