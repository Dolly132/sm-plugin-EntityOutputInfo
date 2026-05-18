# EntityOutputInfo

A [SourceMod](https://www.sourcemod.net/) plugin that exposes a native API for inspecting and manipulating [Source Engine entity outputs](https://developer.valvesoftware.com/wiki/Outputs) at runtime.

Entity outputs are the connections wired between entities in a map (e.g. `OnTrigger → func_door → Open`). This plugin reads the engine's internal datamap structures directly, giving other plugins full read/write access to those connections without relying on I/O hooks.

**Plugin info**
| Field | Value |
|-------|-------|
| Name | Entity Output Info |
| Authors | Botox, Addie, Dolly, .Rushaway |
| SourceMod version | 1.12+ |

---

## Installation

> [!IMPORTANT]
> Only supported on 32 bits for now (Windows/Linux)

1. Download the latest compiled `.smx` from the [Releases](../../releases) page.
2. Place `EntityOutputInfo.smx` in `addons/sourcemod/plugins/`.
3. Restart the server or use `sm plugins load EntityOutputInfo`.

---

## Usage (for plugin developers)

Add the include to your plugin and declare the dependency:

```sourcepawn
#include <EntityOutputInfo>

public void OnPluginStart()
{
    // Example: print all output actions for "OnTrigger" on entity 100
    int count = GetOutputCount(100, "OnTrigger");
    for (int i = 0; i < count; i++)
    {
        char formatted[512];
        GetOutputFormatted(100, "OnTrigger", i, formatted, sizeof(formatted));
        PrintToServer("  [%d] %s", i, formatted);
    }
}
```

To make the dependency optional, compile with `#undef REQUIRE_PLUGIN` before including, or omit the define entirely — the include handles `MarkNativeAsOptional` automatically.

---

## API Reference

All natives are declared in `addons/sourcemod/scripting/include/EntityOutputInfo.inc`.

---

### `GetOutputCount`

Returns the number of actions registered for the given output.

```sourcepawn
native int GetOutputCount(int entity, const char[] output);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `output` | `const char[]` | Output property name (e.g. `"OnTrigger"`) |

**Returns:** Number of actions, or `0` if the output does not exist.

---

### `GetOutputTarget`

Retrieves the target name of an output action at the given index.

```sourcepawn
native int GetOutputTarget(int entity, const char[] output, int index, char[] target, int maxlen);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `output` | `const char[]` | Output property name |
| `index` | `int` | Action index (use `FindOutput` to locate a specific action) |
| `target` | `char[]` | Buffer to store the target name |
| `maxlen` | `int` | Maximum length of the buffer |

**Returns:** Number of bytes written to the buffer.

---

### `GetOutputTargetInput`

Retrieves the target input of an output action at the given index.

```sourcepawn
native int GetOutputTargetInput(int entity, const char[] output, int index, char[] targetInput, int maxlen);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `output` | `const char[]` | Output property name |
| `index` | `int` | Action index |
| `targetInput` | `char[]` | Buffer to store the target input |
| `maxlen` | `int` | Maximum length of the buffer |

**Returns:** Number of bytes written to the buffer.

---

### `GetOutputParameter`

Retrieves the parameter of an output action at the given index.

```sourcepawn
native int GetOutputParameter(int entity, const char[] output, int index, char[] parameter, int maxlen);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `output` | `const char[]` | Output property name |
| `index` | `int` | Action index |
| `parameter` | `char[]` | Buffer to store the parameter |
| `maxlen` | `int` | Maximum length of the buffer |

**Returns:** Number of bytes written to the buffer.

---

### `GetOutputDelay`

Retrieves the delay of an output action at the given index.

```sourcepawn
native float GetOutputDelay(int entity, const char[] output, int index);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `output` | `const char[]` | Output property name |
| `index` | `int` | Action index |

**Returns:** Delay in seconds, or `-1.0` if the output does not exist.

---

### `GetOutputRefires`

Retrieves the refire count of an output action at the given index.

```sourcepawn
native int GetOutputRefires(int entity, const char[] output, int index);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `output` | `const char[]` | Output property name |
| `index` | `int` | Action index |

**Returns:** Number of times the action will fire (`-1` = infinite), or `0` on failure.

---

### `GetOutputFormatted`

Retrieves a formatted string representation of an output action at the given index.

Format: `"target,targetInput,parameter,delay,timesToFire"`

```sourcepawn
native int GetOutputFormatted(int entity, const char[] output, int index, char[] formatted, int maxlen);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `output` | `const char[]` | Output property name |
| `index` | `int` | Action index |
| `formatted` | `char[]` | Buffer to store the formatted string |
| `maxlen` | `int` | Maximum length of the buffer |

**Returns:** Number of bytes written to the buffer.

---

### `GetOutputValue`

Retrieves the integer value stored in the given output. Throws a native error if the output value type is not an integer.

```sourcepawn
native int GetOutputValue(int entity, const char[] output);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `output` | `const char[]` | Output property name |

**Returns:** Integer value of the output.

---

### `GetOutputValueFloat`

Retrieves the float value stored in the given output. Throws a native error if the output value type is not a float.

```sourcepawn
native float GetOutputValueFloat(int entity, const char[] output);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `output` | `const char[]` | Output property name |

**Returns:** Float value of the output.

---

### `GetOutputValueString`

Retrieves the string value stored in the given output. Throws a native error if the output value type is not a string.

```sourcepawn
native int GetOutputValueString(int entity, const char[] output, char[] buffer, int maxlen);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `output` | `const char[]` | Output property name |
| `buffer` | `char[]` | Buffer to store the string value |
| `maxlen` | `int` | Maximum length of the buffer |

**Returns:** Number of bytes written to the buffer.

---

### `GetOutputValueVector`

Retrieves the vector value stored in the given output. Throws a native error if the output value type is not a vector.

```sourcepawn
native bool GetOutputValueVector(int entity, const char[] output, float vec[3]);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `output` | `const char[]` | Output property name |
| `vec` | `float[3]` | Float array of size 3 to store the vector |

**Returns:** `true` on success, `false` otherwise.

---

### `FindOutput`

Searches for an output action matching the given criteria, starting from `startIndex`. Pass `NULL_STRING` or default values to ignore a specific field.

```sourcepawn
native int FindOutput(int entity, const char[] output, int startIndex,
    const char[] target = NULL_STRING,
    const char[] targetInput = NULL_STRING,
    const char[] parameter = NULL_STRING,
    float delay = -1.0,
    int timesToFire = 0);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `output` | `const char[]` | Output property name |
| `startIndex` | `int` | Index to start searching from |
| `target` | `const char[]` | Target name to match, or `NULL_STRING` to ignore |
| `targetInput` | `const char[]` | Target input to match, or `NULL_STRING` to ignore |
| `parameter` | `const char[]` | Parameter to match, or `NULL_STRING` to ignore |
| `delay` | `float` | Delay value to match, or `-1.0` to ignore |
| `timesToFire` | `int` | Refire count to match, or `0` to ignore |

**Returns:** Index of the matching action, or `-1` if not found.

---

### `DeleteOutput`

Deletes the output action at the given index.

```sourcepawn
native bool DeleteOutput(int entity, const char[] output, int index);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `output` | `const char[]` | Output property name |
| `index` | `int` | Action index (use `FindOutput` to locate a specific action) |

**Returns:** `true` on success, `false` otherwise.

---

### `DeleteAllOutputs`

Deletes all actions registered for the given output.

```sourcepawn
native int DeleteAllOutputs(int entity, const char[] output);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `output` | `const char[]` | Output property name |

**Returns:** Number of actions deleted.

---

### `GetOutputNames`

Retrieves the name of an output at the given index by iterating the entity's datamap.

```sourcepawn
native int GetOutputNames(int entity, int index, char[] output, int maxlen);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | `int` | Entity index |
| `index` | `int` | Output index in the datamap |
| `output` | `char[]` | Buffer to store the output name |
| `maxlen` | `int` | Maximum length of the buffer |

**Returns:** Number of bytes written to the buffer.

## License

See [LICENSE](LICENSE) for details.
