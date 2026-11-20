# Druida Sombria — caminhada e gesto ritual (Godot 4.7)

Protótipo de **animação quadro a quadro**, não animação esquelética, criado usando a pose neutra aprovada como referência de direção artística. As novas animações são estudos de poses pintadas; como foram geradas separadamente, há diferenças sutis em proporção e câmera em relação à pose neutra.

## Abrir / testar

Importe `project.godot` na Godot 4.7 e pressione F5.

- `1`: pose neutra aprovada;
- `2`: ciclo contínuo de **8 quadros** de caminhada, no lugar;
- `3` ou `Espaço`: **8 quadros** do gesto ritual, voltando ao estado anterior.

Os arquivos individuais estão em `assets/frames/walk/00.png` a `07.png` e `assets/frames/ritual/00.png` a `07.png`. A pose neutra está em `assets/pose/druida_pose_neutra.png`.

## Publicar via GitHub Pages

Copie o conteúdo deste pacote para a **raiz** do repositório `druida-sombria`, mantendo `.github/workflows/publicar-web.yml` e `export_presets.cfg` já existentes no GitHub. Em seguida:

```powershell
git pull --rebase origin main
git add .
git commit -m "Adicionar caminhada e gesto ritual pintados"
git push origin main
```

A exportação Web deve ser feita pelo workflow existente. Se a compilação falhar, consulte a aba Actions e envie o log para diagnóstico.

## Limitações

- Recortes automatizados de uma prancha ilustrada podem exibir pequenos halos ou artefatos em bordas e alguns quadros (sobretudo perto do cajado).
- A caminhada é estacionária e vista lateral, enquanto a pose neutra é em três quartos; a transição muda o ângulo da câmera.
- O gesto é uma sequência curta e não possui VFX de magia nesta versão.
- Para animação com ossos de qualidade comercial, será necessário redesenhar as partes corretamente sobrepostas e criar pesos de deformação. Estes quadros não são peças separadas.
