# Druida da Floresta Sombria — Godot 4.7 / 4.7.2

## Para abrir no Windows
1. Extraia o arquivo ZIP por completo.
2. Abra o **Godot 4.7 ou 4.7.2** e clique em **Importar**.
3. Selecione o arquivo `project.godot` nesta pasta.
4. Abra a cena `main.tscn` ou execute o projeto com **F5**.

### Controles
- **1**: repouso, com respiração sutil.
- **2**: marcha estacionária, com oscilação dos braços e pernas.
- **3** ou **Espaço**: gesto ritual com cajado.
- Também existem botões na interface.

### O que foi incluído
- Recortes **transparentes** da prancha de pintura, exportados como **21 arquivos PNG separados** (`assets/parts`).
- Hierarquia nativa Godot com `Skeleton2D` e **15 nós `Bone2D`**, preparada por script (`scripts/main.gd`).
- Hierarquia de peças, posições, tamanhos e ordem de desenho em `scripts/parts.gd`.
- A ficha de conceito original, a prancha de peças e a prévia da montagem em `reference/`.

### Limitações importantes
As peças saíram de uma **prancha gerada por IA**, não de um conjunto desenhado originalmente para deformação esquelética. Há pequenas lacunas, discrepâncias de perspectiva e junções de braço/perna que ainda precisam de repintura e sobreposição. Por isso, as animações **são propositalmente moderadas**. O rig não usa ainda malha deformável (`Polygon2D` + pesos), IK ou animações quadros-a-quadro; a marcha não desloca a personagem pelo cenário. O cajado acompanha o osso da mão direita aproximadamente. Esta é a primeira integração jogável/visual de avaliação — não um sprite final pronto para publicação.

O projeto é independente e **não altera seus outros repositórios**. Não requer Spine, plugins ou extensões.

### Validação
A montagem de referência foi gerada e todos os arquivos de projeto foram empacotados. **A execução no binário do Godot não foi testada neste ambiente**; abra no editor para validar importação e possíveis avisos.
