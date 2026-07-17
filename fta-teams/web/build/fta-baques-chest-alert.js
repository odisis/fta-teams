(function () {
  const id = 'fta-baques-chest-placement-alert'
  const styleId = id + '-style'
  let pending = false

  function ensureStyle() {
    if (document.getElementById(styleId)) return
    const style = document.createElement('style')
    style.id = styleId
    style.textContent = `
      #${id} {
        position: fixed;
        left: 50%;
        top: calc(50% - 368px);
        transform: translateX(-50%);
        width: min(520px, 42vw);
        min-height: 42px;
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 0 16px;
        border: 1px solid rgba(235, 52, 72, .55);
        border-left: 3px solid #eb3448;
        background: rgba(13, 13, 18, .96);
        box-shadow: 0 12px 28px rgba(0, 0, 0, .28);
        color: rgba(255, 255, 255, .92);
        font: 600 12px/1.3 Arial, sans-serif;
        letter-spacing: 0;
        z-index: 100000;
        pointer-events: none;
      }
      #${id} strong { color: #ff5264; font-size: 11px; }
      #${id} span { color: rgba(255, 255, 255, .6); font-weight: 400; }
      #${id} .fta-chest-mark {
        position: relative;
        width: 18px;
        height: 14px;
        border: 1px solid #ff5264;
        flex: 0 0 auto;
      }
      #${id} .fta-chest-mark::before {
        content: '';
        position: absolute;
        left: 3px;
        right: 3px;
        top: -5px;
        height: 4px;
        border: 1px solid #ff5264;
      }
      [data-fta-chest-pending='true'] { position: relative !important; }
      [data-fta-chest-pending='true']::after {
        content: '';
        position: absolute;
        right: 8px;
        top: 8px;
        width: 7px;
        height: 7px;
        border-radius: 50%;
        background: #ff334d;
        box-shadow: 0 0 0 3px rgba(255, 51, 77, .16);
      }
    `
    document.head.appendChild(style)
  }

  function markChestEntry() {
    document.querySelectorAll('[data-fta-chest-pending]').forEach((node) => {
      node.removeAttribute('data-fta-chest-pending')
    })
    if (!pending) return

    const nodes = Array.from(document.querySelectorAll('button, li, div, span'))
    const target = nodes.find((node) => {
      const text = (node.textContent || '')
        .trim()
        .toLocaleLowerCase('pt-BR')
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
      return text === 'bau' && node.children.length <= 3
    })
    const entry = target && (target.closest('button, li') || target.parentElement)
    if (entry) entry.setAttribute('data-fta-chest-pending', 'true')
  }

  function render() {
    ensureStyle()
    document.getElementById(id)?.remove()
    if (!pending) {
      markChestEntry()
      return
    }

    const alert = document.createElement('div')
    alert.id = id
    alert.innerHTML = `
      <i class="fta-chest-mark" aria-hidden="true"></i>
      <strong>BAU RECOLHIDO</strong>
      <span>Posicione novamente o bau da organizacao para liberar o acesso.</span>
    `
    document.body.appendChild(alert)
    markChestEntry()
  }

  window.addEventListener('message', (event) => {
    const message = event.data || {}
    if (message.action === 'openGroup') {
      pending = message.data?.chestPlacement?.state === 'pending_placement'
      render()
    } else if (message.action === 'closeGroup') {
      pending = false
      render()
    }
  })

  new MutationObserver(markChestEntry).observe(document.documentElement, {
    childList: true,
    subtree: true
  })
})()
