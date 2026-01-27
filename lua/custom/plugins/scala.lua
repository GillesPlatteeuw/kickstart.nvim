-- Scala support using nvim-metals
return {
  'scalameta/nvim-metals',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'mfussenegger/nvim-dap',
  },
  ft = { 'scala', 'sbt', 'java' },
  opts = function()
    local metals_config = require('metals').bare_config()

    metals_config.settings = {
      showImplicitArguments = true,
      showImplicitConversionsAndClasses = true,
      showInferredType = true,
      superMethodLensesEnabled = true,
      enableSemanticHighlighting = false,
      excludedPackages = { 'akka.actor.typed.javadsl', 'com.github.swagger.akka.javadsl' },
    }

    metals_config.init_options.statusBarProvider = 'off'
    metals_config.capabilities = require('blink.cmp').get_lsp_capabilities()

    metals_config.on_attach = function(client, bufnr)
      require('metals').setup_dap()

      local map = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'Metals: ' .. desc })
      end

      map('<leader>mc', function() require('metals').commands() end, '[C]ommands')
      map('<leader>mi', function() require('metals').import_build() end, '[I]mport Build')
      map('<leader>mo', function() require('metals').organize_imports() end, '[O]rganize Imports')
      map('<leader>mh', function() require('metals').hover_worksheet() end, '[H]over Worksheet')
      map('<leader>mt', function() require('metals').toggle_setting('showImplicitArguments') end, '[T]oggle Implicit Args')
      map('<leader>mr', function() require('metals').restart_metals() end, '[R]estart Server')
      map('<leader>mv', function() require('metals.tvp').toggle_tree_view() end, 'Tree [V]iew')
      map('<leader>mR', function() require('metals.tvp').reveal_in_tree() end, '[R]eveal in Tree')
    end

    return metals_config
  end,
  config = function(self, metals_config)
    vim.opt_global.shortmess:remove('F')

    local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      pattern = self.ft,
      callback = function()
        require('metals').initialize_or_attach(metals_config)
      end,
      group = nvim_metals_group,
    })
  end,
}
