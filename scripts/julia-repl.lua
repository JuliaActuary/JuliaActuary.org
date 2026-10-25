-- Pandoc knows Julia syntax; REPL examples use the same lexer at build time.
function CodeBlock(block)
  for index, class in ipairs(block.classes) do
    if class == "julia-repl" then
      block.classes[index] = "julia"
      return block
    end
  end
end
