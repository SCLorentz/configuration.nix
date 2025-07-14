yad --scale --min-value=0 --max-value=100 --value=$(pamixer --get-volume) \
    --title="Volume" --on-top --width=300 --button="Fechar" --undecorated \
    --mouse --no-buttons --print-partial |
    while read vol; do
      pamixer --set-volume "$vol"
    done