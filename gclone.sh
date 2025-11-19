gclone() {
  if [ -z "$1" ]; then
    echo "Error: Debes proporcionar la URL SSH de Git."
    echo "Uso: gclone <url_ssh_git> [clave]"
    echo "Ejemplo: gclone git@github.com:usuario/repo.git colppy"
    return 1
  fi

  local key=${2:-colppy}
  
  local alias_host=""
  case "$key" in
    colppy)
      alias_host="github.com-colppy"
      ;;
    personal)
      alias_host="github.com-personal"
      ;;
    utn)
      alias_host="github.com-utn"
      ;;
    *)
      echo "Error: Clave SSH '$key' no válida."
      echo "Las claves válidas son: colppy, personal, utn."
      return 1
      ;;
  esac

  local original_url="$1"
  local new_url=$(echo "$original_url" | sed "s/git@github.com/git@$alias_host/")
  git clone "$new_url"
}