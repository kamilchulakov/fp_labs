# Лабораторная работа №2

## Вариант

### 3. Prefix Tree Set
- https://en.wikipedia.org/wiki/Trie

## Цель работы

Освоиться с построением пользовательских типов данных, полиморфизмом, рекурсивными алгоритмами и средствами
тестирования (unit testing, property-based testing).

## Требования к разработанному ПО

1. Функции:
   - добавление и удаление элементов;
   - фильтрация;
   - отображение (map);
   - свертки (левая и правая);
   - структура должна быть моноидом.

2. Структуры данных должны быть неизменяемыми.
3. Библиотека должна быть протестирована в рамках unit testing.
4. Библиотека должна быть протестирована в рамках property-based тестирования (как минимум 3 свойства, включая свойства
   моноида).
5. Структура должна быть полиморфной.
6. Требуется использовать идиоматичный для технологии стиль программирования. Примечание: некоторые языки позволяют
   получить большую часть API через реализацию небольшого интерфейса. Так как лабораторная работа про ФП, а не про
   экосистему языка -- необходимо реализовать их вручную и по возможности -- обеспечить совместимость.

## Особенности реализации

### Чистые модули

- Модуль - единица абстракции
- Чистые модули не содержат собственного состояния (pure ~ stateless)
- Функции-модификаторы возвращают измененную абстракцию. Пример: `String.upcase/1`
- Функции-запросы возвращают данные другого типа. Пример: `String.length/1`

```kotlin
object PureStringModule {
   fun upcase(string: String): String = string.uppercase()
   fun length(string: String): Int = string.length
}

object PureExtensionsStringModule {
   fun String.upcase(): String = uppercase()
   fun String.length(): Int = length
}
```

### Узлы дерева = Записи

> Records are simply tuples where the first element is an atom.

Атом — константа, название которой является и значением.

У записи есть поля и значения:

```elixir
require Record

Record.defrecord(:trie_node, x: nil, children: [], word: nil)
```

Сгенерирует 3 макроса:
- `trie_node/0` — для создания записи с дефолтными значениями
- `trie_node/1` — для создания записи с 1 параметризованным значением или для получения индекса поля в кортеже
- `trie_node/2` — для изменения записи или доступа к полю

**Оказалось жутко удобным.**

\- https://hexdocs.pm/elixir/Record.html#defrecord/3

### Модуль List для операций со списками (дочерних узлов, слов)
- Не привязан к типам.

```elixir
defmodule Trie.List do
  @spec foldl(list :: list(), acc :: any(), fun :: function()) :: any()
  def foldl([], acc, _), do: acc
  def foldl([head | tail], acc, fun), do: foldl(tail, fun.(head, acc), fun)

  @spec foldr(list :: list(), acc :: any(), fun :: function()) :: any()
  def foldr([], acc, _), do: acc
  def foldr([head | tail], acc, fun), do: fun.(head, foldr(tail, acc, fun))

  @spec find(list :: list(), predicate :: function()) :: any()
  def find([], _), do: nil

  def find(set, predicate) do
    [first | _] = filter(set, predicate)
    first
  end

  @spec filter(list :: list(), predicate :: function()) :: any()
  def filter([], _), do: []

  def filter(set, predicate) do
    foldl(set, [], &add_if(&2, &1, predicate))
  end

  @spec map_if(list :: list(), predicate :: function(), mapper :: function()) :: list()
  def map_if([], _, _), do: []

  def map_if([head | tail], predicate, mapper) do
    fun = fn x, acc ->
      case predicate.(x) do
        true -> [mapper.(x) | acc]
        _ -> acc
      end
    end

    foldl(tail, fun.(head, []), fun)
  end

  @spec map(list :: list(), mapper :: function()) :: list()
  def map(list, mapper), do: foldl(list, [], &(&2 ++ [mapper.(&1)]))

  @spec merge(list :: list(), other :: list()) :: list()
  def merge(list, other), do: list ++ other

  @spec add_if(list :: list(), value :: any(), predicate :: function()) :: list()
  defp add_if([], x, predicate) do
    case predicate.(x) do
      true -> [x]
      false -> []
    end
  end

  defp add_if([set], x, predicate) do
    case predicate.(x) do
      true -> [set, x]
      false -> [set]
    end
  end
end
```

### Почему не X для дочерних узлов?
\- https://hexdocs.pm/elixir/keywords-and-maps.html

- Очень хотел перейти на `Keywords List` вместо обычно списка, но протокол не гарантирует список атомов.
- `Map` часто требует работы через свой API. 


### Полиморфизм через протокол
> Good designs tend to be more explicit, so let's also model the unarmed scenario by creating a Weapon that doesn't affect the warrior's power.

\- https://blog.10pines.com/2023/05/22/expressive-design-in-elixir-with-polymorphic-protocols/

```elixir
defprotocol Trie.Wordable do
  def to_wordable(data)
end

defimpl Trie.Wordable, for: List do
  def to_wordable(list) when length(list) != 0, do: list
end

defimpl Trie.Wordable, for: Tuple do
  def to_wordable(tuple) when tuple_size(tuple) != 0, do: Tuple.to_list(tuple)
end

defimpl Trie.Wordable, for: BitString do
  def to_wordable(str), do: to_charlist(str)
end

defimpl Trie.Wordable, for: Atom do
  def to_wordable(atom), do: Atom.to_charlist(atom)
end

defimpl Trie.Wordable, for: Integer do
  def to_wordable(integer), do: Integer.digits(integer)
end
```

- Entries are sorted, if guard matches (when it is allowed by type)
```elixir
defp insert_child(children = [head | _], [x], word) when trie_node(head, :x) > x,
   do: [word_node(x, word) | children]

defp insert_child([head | tail], [x], word) when trie_node(head, :x) != x,
   do: [head | insert_child(tail, [x], word)]
```

### Коллизии слов
- Сохраняется только первое слово
```elixir
def insert(node, [x], word) when trie_node(node, :x) == x and trie_node(node, :word) == nil,
   do: trie_node(node, word: word)

def insert(node, [x], _) when trie_node(node, :x) == x and trie_node(node, :word) != nil,
    do: node
```

```kotlin
data class Message(val text: String) {
   override fun hashCode(): Int = 1
   override fun equals(other: Any?) = true
}

fun main() {
   val data = mutableSetOf(Message("haha"))
   data.add(Message("hihi"))
   println(data) // [Message(text=haha)]
   println(data.any({ it.text == "hihi"})) // false
   println(data == mutableSetOf(Message("hihi"))) // true
}
```

### Trie
```elixir
defmodule Trie do
  @moduledoc """
  Implements a Trie.

  ### Links
    - https://en.wikipedia.org/wiki/Trie
  """

  require Record
  require Trie.Node

  alias Trie.List
  alias Trie.Node
  alias Trie.Wordable

  @enforce_keys [:root]
  defstruct [:root]

  @typedoc """
    Type that represents #{Trie.Node} value.
    Only root nodes have nil.
  """
  @type x :: char() | integer() | binary() | nil

  @typedoc """
    Type that represents stored word.
  """
  @type word :: Wordable.t()

  @type t :: %__MODULE__{root: Node.trie_node(x())}

  @spec new() :: t()
  def new, do: %__MODULE__{root: Node.trie_node()}

  @spec new(words :: list(word())) :: t()
  def new(words),
    do:
      new()
      |> add_all(words)

  @spec insert(trie :: t(), word :: word()) :: t()
  def insert(%__MODULE__{root: root}, word) do
    %__MODULE__{
      root: Node.insert(root, Wordable.to_wordable(word), word)
    }
  end

  @spec entries(trie :: t()) :: [word()]
  def entries(%__MODULE__{root: root}), do: Node.entries(root)

  @spec search(trie :: t(), prefix: word()) :: [word()]
  def search(%__MODULE__{root: root}, prefix), do: Node.search(root, Wordable.to_wordable(prefix))

  @spec add(trie :: t(), word :: word()) :: t()
  def add(trie, word), do: insert(trie, word)

  @spec add_all(trie :: t(), words :: list(word())) :: t()
  def add_all(trie, words), do: List.foldl(words, trie, &add(&2, &1))

  @spec remove(trie :: t(), word :: word()) :: t()
  def remove(%__MODULE__{root: root}, word),
    do: %__MODULE__{root: Node.remove(root, Wordable.to_wordable(word))}

  @spec foldl(trie :: t(), acc :: any(), fun :: function()) :: any()
  def foldl(trie, acc, fun) do
    trie
    |> entries
    |> List.foldl(acc, fun)
  end

  @spec foldr(trie :: t(), acc :: any(), fun :: function()) :: any()
  def foldr(trie, acc, fun) do
    trie
    |> entries
    |> List.foldr(acc, fun)
  end

  @spec filter(trie :: t(), predicate :: function()) :: t()
  def filter(trie, predicate) do
    trie
    |> entries
    |> List.filter(predicate)
    |> new
  end

  @spec map(trie :: t(), mapper :: function()) :: t()
  def map(trie, mapper) do
    trie
    |> entries
    |> List.map(mapper)
    |> new
  end

  @spec merge(trie :: t(), other :: t()) :: t()
  def merge(trie, other) do
    trie
    |> add_all(entries(other))
  end

  @spec equals?(trie :: t(), other :: t()) :: boolean()
  def equals?(%__MODULE__{root: root}, %__MODULE__{root: other_root}) do
    root
    |> Node.equals?(other_root)
  end
end
```

### Property tests
\- https://en.wikipedia.org/wiki/Monoid

```elixir
defmodule TriePropertyTest do
  use ExUnit.Case
  use ExUnitProperties

  property "Identity element" do
    check all(trie <- trie_generator()) do
      empty_trie = Trie.new()

      assert Trie.equals?(Trie.merge(empty_trie, trie), trie)
      assert Trie.equals?(Trie.merge(trie, empty_trie), trie)
    end
  end

  property "Associativity" do
    check all(trie1 <- trie_generator(), trie2 <- trie_generator(), trie3 <- trie_generator()) do
      assert Trie.equals?(
               Trie.merge(Trie.merge(trie1, trie2), trie3),
               Trie.merge(trie1, Trie.merge(trie2, trie3))
             )
    end
  end

  property "Sorted entries" do
    check all(trie <- trie_generator()) do
      entries = Trie.entries(trie)

      assert entries == Enum.sort_by(entries, &Integer.digits/1)
    end
  end

  defp trie_generator do
    gen all(words <- list_of(integer())) do
      Trie.new(words)
    end
  end
end
```

### Проблемы с инструментами

- Ignoring `gradient` warnings for:
```
Typechecking files...
lib/trie/wordable.ex: The spec 'impl_for!'/1 on line 1 doesn't match the function name/arity
lib/trie/wordable.ex: Call to undefined function Trie.Wordable.Map.'__impl__'/1 on line 1
```

## Вывод
В ходе работы познакомился с ключевыми концепциями в Elixir: `Struct`, `Behaviour`, `Protocol`, `Keywords List`, `Map`, `Record`, понял в чём отличие `use`, `alias` и `require`, немного узнал про макросы, научился пользовать ковром (cover - инструмент измерения test coverage в экосистеме Elixir) и дергать его в Github Action.



