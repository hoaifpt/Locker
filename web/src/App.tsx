export default function App() {
    return (
        <div className="min-h-screen bg-amber-50 px-6 py-12 text-stone-900">
            <header className="mx-auto mb-8 max-w-3xl">
                <p className="text-sm font-semibold uppercase tracking-[0.2em] text-amber-700">
                    Locker dashboard
                </p>
                <h1 className="mt-3 text-4xl font-semibold leading-tight md:text-5xl">
                    Locker Control Center
                </h1>
                <p className="mt-3 text-lg text-stone-600">
                    Client-side rendered experience, fast to load and easy to scale.
                </p>
            </header>

            <section className="mx-auto grid max-w-3xl gap-6 md:grid-cols-2">
                <div className="rounded-2xl border border-amber-200 bg-white p-6 shadow-lg shadow-amber-100">
                    <h2 className="text-lg font-semibold">Status</h2>
                    <p className="mt-2 text-sm text-stone-600">
                        No data yet. Connect API to show lockers.
                    </p>
                </div>
                <div className="rounded-2xl border border-amber-200 bg-white p-6 shadow-lg shadow-amber-100">
                    <h2 className="text-lg font-semibold">Next step</h2>
                    <p className="mt-2 text-sm text-stone-600">
                        Add API client and live updates for locker telemetry.
                    </p>
                </div>
            </section>
        </div>
    );
}
