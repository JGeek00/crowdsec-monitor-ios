# Patrones para Gestionar Estados de Peticiones HTTP en SwiftUI

## ✅ Opción 1: Enum de Estado (IMPLEMENTADO - Recomendado)

Esta es la solución más limpia y type-safe. Ya está implementada en tu proyecto.

### Ventajas:
- **Type-safe**: El compilador garantiza que manejes todos los casos
- **Un solo source of truth**: Solo una variable `state` en lugar de múltiples booleanos
- **Más fácil de testear**: Estados mutuamente exclusivos
- **Previene estados inválidos**: No puedes tener `loading = true` y `error = true` al mismo tiempo

### Uso:
```swift
enum LoadingState<T> {
    case idle       // Estado inicial (sin datos, sin carga)
    case loading    // Cargando datos
    case success(T) // Datos cargados correctamente
    case failure(Error) // Error al cargar
}
```

### En la vista (con switch):
```swift
switch viewModel.state {
case .idle:
    ContentUnavailableView(...)
case .loading:
    ProgressView(...)
case .success(let data):
    ContentView(data: data)
case .failure(let error):
    ErrorView(error: error)
}
```

---

## 🔄 Opción 2: Múltiples Propiedades Booleanas

Esta es la forma antigua que tenías antes. **No recomendada** pero funcional.

### Desventajas:
- Estados inconsistentes posibles (ej: `loading = true` y `error = true`)
- Más código para validar
- Difícil de testear
- No type-safe

```swift
var data: StatisticsResponse? = nil
var loading: Bool = false
var error: Error? = nil

// En la vista necesitas if-else anidados
if loading {
    ProgressView()
} else if let error = error {
    ErrorView(error: error)
} else if let data = data {
    ContentView(data: data)
} else {
    EmptyView()
}
```

---

## 🎯 Opción 3: Enum Genérico Reutilizable (Avanzado)

Puedes mover el enum a un archivo separado para reutilizarlo:

```swift
// En Utils/LoadingState.swift
enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)
    
    // Computed properties útiles
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var data: T? {
        if case .success(let data) = self { return data }
        return nil
    }
    
    var error: Error? {
        if case .failure(let error) = self { return error }
        return nil
    }
}
```

Luego úsalo en cualquier ViewModel:

```swift
class UserViewModel {
    var state: LoadingState<User> = .idle
}

class PostsViewModel {
    var state: LoadingState<[Post]> = .idle
}
```

---

## 🎨 Opción 4: Vista Reutilizable (Componente)

Puedes crear un componente que maneje automáticamente los estados:

```swift
// En Views/Components/AsyncContentView.swift
struct AsyncContentView<Data, Content: View>: View {
    let state: LoadingState<Data>
    let content: (Data) -> Content
    
    var body: some View {
        switch state {
        case .idle:
            ContentUnavailableView(
                "No Data",
                systemImage: "tray",
                description: Text("Pull to refresh")
            )
        case .loading:
            ProgressView()
        case .success(let data):
            content(data)
        case .failure(let error):
            ContentUnavailableView(
                "Error",
                systemImage: "exclamationmark.triangle",
                description: Text(error.localizedDescription)
            )
        }
    }
}

// Uso simplificado en cualquier vista:
AsyncContentView(state: viewModel.state) { data in
    DashboardContent(data: data)
}
```

---

## 🚀 Opción 5: Con Retry y Loading Overlay

Para casos más complejos donde necesitas mostrar loading sobre contenido existente:

```swift
enum LoadingState<T> {
    case idle
    case loading(T?) // Puede tener datos previos mientras recarga
    case success(T)
    case failure(Error, T?) // Mantiene datos previos si falla el refresh
    
    var data: T? {
        switch self {
        case .idle: return nil
        case .loading(let data): return data
        case .success(let data): return data
        case .failure(_, let data): return data
        }
    }
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

// En la vista:
ZStack {
    if let data = viewModel.state.data {
        ContentView(data: data)
    } else {
        EmptyStateView()
    }
    
    if viewModel.state.isLoading {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.2))
    }
}
```

---

## 📊 Comparación

| Patrón | Simplicidad | Type Safety | Reutilizable | Testeable |
|--------|-------------|-------------|--------------|-----------|
| Enum (actual) | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Booleanos múltiples | ⭐⭐ | ⭐ | ⭐⭐ | ⭐⭐ |
| Componente reutilizable | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Con datos previos | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## 🎓 Mejores Prácticas

1. **Usa enum de estados** - Es el estándar en la comunidad Swift/SwiftUI
2. **Hazlo genérico** - Reutiliza el mismo enum para todos tus ViewModels
3. **Maneja todos los casos** - Siempre usa `switch` exhaustivo, no `if case`
4. **Separa concerns** - ViewModel gestiona estado, Vista solo renderiza
5. **Considera retry** - Agrega un botón de retry en el estado de error
6. **Pull to refresh** - Usa `.refreshable` para recargar (ya implementado)
7. **Mantén datos previos** - En algunos casos, mantén datos viejos mientras recargas

---

## 🔥 Tu Implementación Actual

Tu código ahora usa el patrón **Enum de Estado**, que es considerado la mejor práctica por:
- Apple en sus ejemplos de SwiftUI
- La comunidad de desarrolladores iOS
- Es usado en frameworks como The Composable Architecture (TCA)

¡Estás usando el patrón correcto! 🎉
