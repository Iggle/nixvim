{
  lib,
  helpers,
  config,
  ...
}:
with lib; let
  filetypeDefinition = helpers.mkNullOrOption (types.attrsOf (
    types.oneOf [
      # Raw filetype
      types.str
      # Function to set the filetype
      helpers.rawType
      # ["filetype" {priority = xx;}]
      (types.listOf (types.either types.str (types.submodule {
        options = {
          priority = mkOption {
            type = types.int;
          };
        };
      })))
    ]
  ));
in {
  options.filetype =
    helpers.mkCompositeOption ''
      Define additional filetypes. The values can either be a literal filetype or a function
      taking the filepath and the buffer number.

      For more information check `:h vim.filetype.add()`
    '' {
      extension = filetypeDefinition "set filetypes matching the file extension";
      filename = filetypeDefinition "set filetypes matching the file name (or path)";
      pattern = filetypeDefinition "set filetypes matching the specified pattern";
    };

  config.extraConfigLua = helpers.mkIfNonNull' config.filetype ''
    vim.filetype.add(${helpers.toLuaObject config.filetype})
  '';
}
