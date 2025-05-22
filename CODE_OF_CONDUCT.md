# Mejorando el contenido de index.mdx con estructura clara, etiquetas semánticas, SEO y accesibilidad

better_index_mdx = '''---
title: x5368x — Dotfiles & Ricing
description: Perfil de x5368x, experto en personalización de entornos Linux como HyprZent v1.
---

import GitHubIcon from '../components/icons/github.svg'
import DiscordIcon from '../components/icons/discord.svg'
import TikTokIcon from '../components/icons/tiktok.svg'
import YouTubeIcon from '../components/icons/youtube.svg'

<style>{`
  :root {
    --accent: #3b82f6;
    --text-light: #888;
    --max-width: 720px;
  }

  body {
    font-family: system-ui, sans-serif;
    line-height: 1.6;
    padding: 0 1rem;
    color: #fff;
    background: #0d1117;
  }

  a {
    color: var(--accent);
    text-decoration: none;
  }

  a:hover {
    text-decoration: underline;
  }

  header, section, footer {
    max-width: var(--max-width);
    margin: 3rem auto;
  }

  header h1 {
    font-size: 3rem;
    font-weight: 800;
    margin-bottom: 0.2rem;
  }

  header p {
    font-size: 1.25rem;
    color: var(--text-light);
  }

  .contact-list {
    display: grid;
    gap: 1rem;
    margin-top: 1.5rem;
  }

  .contact-item {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    font-size: 1.1rem;
  }

  .contact-icon {
    width: 24px;
    height: 24px;
    flex-shrink: 0;
    fill: currentColor;
  }

  ul {
    padding-left: 1.5rem;
  }

  footer {
    text-align: center;
    font-weight: 600;
    font-size: 1.2rem;
    margin-bottom: 4rem;
  }
`}</style>

<header>
  <h1>x5368x</h1>
  <p>Linux Ricer · Dotfile Engineer · Visual Designer</p>
</header>

<main>
  <section aria-labelledby="about-me">
    <h2 id="about-me">Sobre mí</h2>
    <p>
      Soy <strong>x5368x</strong>, diseñador de entornos personalizados en Linux, especializado en <em>Hyprland</em>. Me enfoco en ofrecer configuraciones estéticas, funcionales y fáciles de instalar para usuarios avanzados de Arch Linux.
    </p>
    <p>
      Actualmente desarrollo <strong>HyprZent v1</strong>, un entorno modular, oscuro y altamente visual para una experiencia de usuario fluida.
    </p>
  </section>

  <section aria-labelledby="contact">
    <h2 id="contact">Contacto & Redes</h2>
    <div className="contact-list">
      <div className="contact-item">
        <GitHubIcon className="contact-icon" />
        GitHub: <a href="https://github.com/ProDots/HyprZent-v2" target="_blank" rel="noopener noreferrer">@x5368x</a>
      </div>
      <div className="contact-item">
        <DiscordIcon className="contact-icon" />
        Discord: <a href="https://discord.gg/NdtChxcaU8" target="_blank" rel="noopener noreferrer">Servidor HyprZent</a> (<code>x_536.8</code>)
      </div>
      <div className="contact-item">
        <TikTokIcon className="contact-icon" />
        TikTok: <a href="https://www.tiktok.com/@x_536.8" target="_blank" rel="noopener noreferrer">@x_536.8</a>
      </div>
      <div className="contact-item">
        <YouTubeIcon className="contact-icon" />
        YouTube: <a href="https://youtube.com/@xzn-q7n9q?si=jgDOsYd3g6pmvyw" target="_blank" rel="noopener noreferrer">@xzn-q7n9q</a>
      </div>
    </div>
  </section>

  <section aria-labelledby="project">
    <h2 id="project">HyprZent v1</h2>
    <p>
      <strong>HyprZent</strong> es un entorno visual completo con:
    </p>
    <ul>
      <li>Instalación automatizada (<code>install.sh</code>, <code>set-theme.sh</code>)</li>
      <li>Temas populares: Catppuccin, Dracula, Nord, Gruvbox</li>
      <li>Wallpapers 4K</li>
      <li>Colores dinámicos con <code>pywal</code> + <code>swww</code></li>
      <li>Diseño modular, ligero y coherente</li>
    </ul>
    <p>
      Explora el código en:  
      <a href="https://github.com/ProDots/HyprZent-v2" target="_blank" rel="noopener noreferrer">github.com/ProDots/HyprZent-v2</a>
    </p>
  </section>

  <section aria-labelledby="roadmap">
    <h2 id="roadmap">¿Qué sigue?</h2>
    <p>Próximamente:</p>
    <ul>
      <li>Instalación con un solo comando</li>
      <li>Dotfiles sincronizados con estilo visual</li>
      <li>Actualizaciones OTA para los módulos visuales</li>
    </ul>
  </section>
</main>

<footer>
  Gracias por visitar.<br />
  <em>HyprZent v1 estará disponible muy pronto.</em>
</footer>
'''

# Guardar el archivo mejorado
better_index_path = Path("/mnt/data/index.mdx")
better_index_path.write_text(better_index_mdx)
better_index_path.name
