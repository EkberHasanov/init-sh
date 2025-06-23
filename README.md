# init-sh

A lightweight, minimal init system for containers - inspired from `Tini` and `dumb-init`.

## Why init-sh?

In containers, PID 1 has special responsibilities:
- **Reaping zombie processes** to prevent resource exhaustion
- **Forwarding signals** to child processes for graceful shutdown
- **Proper exit code propagation** from your application with closing DB connections properly and etc...

While excellent solutions like [Tini](https://github.com/krallin/tini) and [dumb-init](https://github.com/Yelp/dumb-init) exist, I built my own simple and customizable init system for the company I am working for, Eigen Ltd. I thought this could be great open source solution which can be used and assessed by other Developers and DevOps engineers.

**init-sh** is:
- pure bash** (vs Tini's ~1000 lines of C)
- **Zero dependencies** - just bash
- **Configurable process targeting** - forward signals to specific processes
- **Easy to understand and modify** - it's just a shell script! - which means you can download this script and customize it for your own needs.

## Quick Start

### Basic Usage

```dockerfile
COPY init-sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-sh

ENTRYPOINT ["/usr/local/bin/init-sh", "--"]
CMD ["node", "server.js"]
```

### Advanced Usage

Forward signals to specific process patterns:

```bash
init-sh -p node -p python -- myapp

# You could also use environment variables
INIT_SH_PROCESS_MATCH="node,python" init-sh -- myapp

# Forward specific signals
init-sh -s TERM -s HUP -p nginx -- nginx -g "daemon off;"
```

## Installation

```bash
wget https://raw.githubusercontent.com/EkberHasanov/init-sh/main/init-sh
chmod +x init-sh
```

```dockerfile
# Or in your Dockerfile
ADD https://raw.githubusercontent.com/EkberHasanov/init-sh/main/init-sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-sh
```

## Features

### Dynamic Process Targeting
This is where the init-sh shines; it is not hard-coded, init-sh lets you specify which processes should get forwarded signals:

```bash
# Forward to Node.js processes
init-sh -p node -- my-app

# Forward to multiple process types
init-sh -p node -p python -p ruby -- my-app

# Use environment variables for configuration
export INIT_SH_PROCESS_MATCH="node,python"
init-sh -- my-app
```

### Verbose Mode
You could also debug what's going on with verbose output and go in the script and make the necessary adjustments as it is just a single bash script

```bash
init-sh -v -- my-app
# [init-sh] Starting init-sh with PID 1
# [init-sh] Process patterns: node python
# [init-sh] Starting command: my-app
# [init-sh] Main child process started with PID: 7
```

### Configurable Signal Handling
Choose which signals to forward:

```bash
# Forward TERM and HUP signals only
init-sh -s TERM -s HUP -- my-app

# Or use environment variables
INIT_SH_SIGNALS="TERM,HUP,USR1" init-sh -- my-app
```

### Automatic Zombie Reaping
Automatically reaps zombie processes to prevent PID exhaustion. - Saw this feature from Tini

## Configuration

### Command Line Options

- `-p PATTERN` - Process pattern to match for signal forwarding (repeatable)
- `-s SIGNAL` - Signal to forward (default: TERM, INT)
- `-v` - Enable verbose output
- `-h` - Show help

### Environment Variables

- `INIT_SH_PROCESS_MATCH` - Comma-separated list of process patterns
- `INIT_SH_SIGNALS` - Comma-separated list of signals to forward
- `INIT_SH_VERBOSE` - Set to "1" to enable verbose output

## Examples

### Node.js Application

You can check examples/node folder to see how I configured init-sh for express app

### Python Application with Gunicorn

Same thing goes for Python as well. There are two examples:
- Simple Flask app
- IN THE FUTURE: (Django app with migrations script in custom entrypoint.sh)

### Multi-Process Application

```bash
# Forward signals to both nginx and node processes
init-sh -p nginx -p node -- supervisord -n
```

## Comparison

| Feature | init-sh | Tini | dumb-init |
|---------|-----------|------|-----------|
| Language | Bash | C | C |
| Size | 4.1KB | ~24KB | ~40-60KB |
| Dependencies | None | libc | libc |
| Configurable process targeting | ✅ | ❌ | ❌ |
| Subreaper support | ❌ | ✅ | ✅ |
| Static binary available | N/A | ✅ | ✅ |
| Lines of code | 171 | 783 | 340 |

## When to Use init-sh

✅ **Use init-sh when:**
- You need a simple, understandable init system
- You want to forward signals to specific processes
- You prefer configuration through environment variables
- You're already using a bash-capable base image
- You need something you can easily modify

❌ **Consider alternatives when:**
- You need a static binary for scratch containers
- You require Linux subreaper functionality
- You need the absolute smallest possible size
- You're running on non-Linux systems

## Contributing

Contributions are welcome! The entire source is less than 100 lines of bash, making it easy to understand and modify.

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Acknowledgments

I was given the task to solve PID management for our applications' containers and I came up with this solution inspired by the excellent [Tini](https://github.com/krallin/tini) and [dumb-init](https://github.com/Yelp/dumb-init) projects. init-sh aims to provide a simpler alternative for cases where you need more flexibility with less complexity.
