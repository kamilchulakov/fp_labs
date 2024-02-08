# Лабораторная работа №1

## Вариант

#### 3. Prefix Tree Set

- https://en.wikipedia.org/wiki/Trie
- http://blog.josephwilk.net/elixir/sets-in-elixir.html (read part about Trie after X commit)

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

### Записи

> Records are simply tuples where the first element is an atom.

Атом — константа, название которой является и значением.

У записи есть поля и значения:

```elixir
require Record

Record.defrecord(:node, children: [], is_end: false)
```

Сгенерирует 3 макроса:

- `node/0` — для создания записи с дефолтными значениями
- `node/1` — для создания записи с 1 параметризованным значением или для получения индекса поля в кортеже
- `node/2` — для изменения записи или доступа к полю

- https://hexdocs.pm/elixir/Record.html#defrecord/3

### Trie specs

```elixir
@spec insert(trie :: t, word :: String.t) :: t
@spec delete(trie :: t, word :: String.t) :: t
@spec search(trie :: t, prefix :: String.t) :: [trie_node]
```

## Trie in Kotlin

- My old solution for [LeetCode](https://leetcode.com/problems/implement-trie-prefix-tree)

```kotlin
class Trie {
   private val root = Node()
   fun insert(word: String) {
      var nd = root
      for (i in word.indices) {
         if (!nd.has(word[i])) nd.children[word[i]] = Node()
         nd = nd.child(word[i])
      }
      nd.isEnd = true
   }

   fun search(word: String): Boolean {
      var nd = root
      for (i in word.indices) {
         if (!nd.has(word[i])) return false
         nd = nd.child(word[i])
      }
      return nd.isEnd
   }

   fun startsWith(prefix: String): Boolean {
      var nd = root
      for (i in prefix.indices) {
         if (!nd.has(prefix[i])) return false
         nd = nd.child(prefix[i])
      }
      return true
   }
}

class Node(
   var isEnd: Boolean = false,
   val children: MutableMap<Char, Node> = mutableMapOf()
) {
   fun has(c: Char) = children[c] != null
   fun child(c: Char) = children[c]!!
}
```

- https://blog.10pines.com/2023/05/22/expressive-design-in-elixir-with-polymorphic-protocols/

> Good designs tend to be more explicit, so let's also model the unarmed scenario by creating a Weapon that doesn't affect the warrior's power.

- https://hexdocs.pm/elixir/Access.html

- https://hexdocs.pm/elixir/keywords-and-maps.html

- http://elixir-br.github.io/getting-started/meta/domain-specific-languages.html
- https://hexdocs.pm/elixir/main/macro-anti-patterns.html


- ignoring `gradient` warnings for:
```
Typechecking files...
lib/trie/wordable.ex: The spec 'impl_for!'/1 on line 1 doesn't match the function name/arity
lib/trie/wordable.ex: Call to undefined function Trie.Wordable.Map.'__impl__'/1 on line 1
```

- Kotlin сохраняет только первое слово
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

- entries are sorted, if guard matches (when it is allowed by type)
- https://en.wikipedia.org/wiki/Monoid