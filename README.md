# Murmuration

## Beta Release 1.0

An interactive browser simulation of 10–10,000 starlings by Lawrence Knowles.

Move a mouse, finger, or stylus across the sky to control a bird of prey. The flock responds through seven-neighbour awareness, a 100 ms baseline reaction, smooth turn limits, variable speed, banking, and locally propagated fear. Every bird also moves forward and backward through simulated depth, changing its apparent size, opacity and drawing layer. **Ground view** places a stationary observer beneath an expansive half-mile volume of sky. A checked-by-default **Auto track** toggle smoothly follows the densest three-dimensional part of the murmuration; manual drag, swipe, and arrow-key looks take temporary priority, or Auto track can be disabled for a fully manual view. At `1×`, individuals cruise between 10 and 14 m/s around a 12 m/s reference and can reach 22 m/s during escape or formation pressure; the **Speed** slider accelerates the complete simulation up to `5×`. The opening scene defaults to 2,500 birds at `4×`, while the count control permits up to 10,000 on capable hardware.

## Features

- Adjustable flock size from 10 to 10,000 birds (2,500 by default)
- Adjustable simulation speed from 1× to 5×
- Seven influential neighbours per bird, with distance and field-of-view weighting
- Predator avoidance and local fear propagation
- Smooth steering, individual speed variation, banking, and natural wandering
- Simulated forward/back flight with perspective scaling, atmospheric fading, and depth-aware flock interaction
- Optional ground-observer view beneath a deep half-mile airspace with full 3D flock forces and perspective projection
- Smoothed drag, swipe, and arrow-key head controls for looking left, right, up, and down
- Optional automatic head tracking of the densest 3D flock neighbourhood
- Overhead viewpoint graphic showing the flock, dense core, viewing cone, and head tilt
- Occasional dense, accelerating ribbon and vortex formations
- Seamless screen wrapping or an optional soft bounding box
- Toggleable blue-grey haze and drifting wispy clouds
- Optional dusk scene with moonrise, warm afterglow, and additional grey cloud banks
- Mouse, touch, stylus, and mobile support
- Adaptive spatial indexing for large flocks

## Flight model

Each animation frame builds a spatial index, finds each bird's seven closest influential neighbours, and combines alignment, cohesion, and collision separation. Neighbours are weighted by distance, field of view, and altitude. Predator fear propagates locally through the same network, while occasional flock-wide vector fields create compression, ribbon, and vortex events.

The update is two-phase: all birds read the same simulation state, proposed positions and velocities are stored separately, and the flock is committed together. This avoids array-order artefacts. Ground view uses a three-dimensional spatial hash and an expanded front-to-back perspective projection without changing physical velocity. Source comments in `assets/murmuration.js` document the equations and update stages alongside the implementation.

The half-mile reference width calibrates `1×` to a 12 m/s cruise, with 10–14 m/s individual preferences, a 22 m/s ceiling, and a 100 ms baseline steering response. The speed slider advances simulation time rather than silently redefining those biological limits.

## Run locally

No build step or dependencies are required. Serve the repository directory with any static web server:

```sh
npx serve .
```

Then open the displayed local URL. Opening `index.html` directly also works in most browsers.

## Deployment

The project is a build-free static site and can be hosted by any service that serves HTML, CSS, and JavaScript. Copy `index.html`, `assets/murmuration.css`, and `assets/murmuration.js` while preserving the `assets/` directory.

The included PowerShell helper is deliberately environment-neutral. Supply your own SSH host, document-root path, port, and optional public URL at runtime:

```powershell
.\deploy.ps1 `
  -RemoteHost 'user@example-host' `
  -RemotePath '/path/to/document-root' `
  -Port 22 `
  -PublicUrl 'https://example.com/'
```

The remote account must already have permission to write to the selected path. Keep credentials, host aliases, private addresses, service names, and environment-specific paths outside this public repository. For managed static hosts, upload the same three files or connect the repository using the platform's normal static-site workflow.

## Licence

Released under the [MIT Licence](LICENSE).
