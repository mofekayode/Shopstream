export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100">
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold text-gray-900">Shopstream</h1>
            </div>
            <nav className="flex space-x-4">
              <a href="#features" className="text-gray-600 hover:text-gray-900">Features</a>
              <a href="#architecture" className="text-gray-600 hover:text-gray-900">Architecture</a>
              <a href="#docs" className="text-gray-600 hover:text-gray-900">Docs</a>
            </nav>
          </div>
        </div>
      </header>

      <main>
        <section className="py-20 text-center">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <h2 className="text-5xl font-bold text-gray-900 mb-4">
              Production-Grade E-commerce Platform
            </h2>
            <p className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto">
              A reference implementation showcasing microservices, event streaming, 
              and modern cloud-native patterns built on AWS
            </p>
            <div className="flex justify-center space-x-4">
              <button className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                View Demo
              </button>
              <button className="px-6 py-3 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300">
                View GitHub
              </button>
            </div>
          </div>
        </section>

        <section id="features" className="py-16 bg-white">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <h3 className="text-3xl font-bold text-center mb-12">Key Features</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              <div className="text-center">
                <div className="w-16 h-16 bg-blue-100 rounded-lg mx-auto mb-4 flex items-center justify-center">
                  <span className="text-2xl">🎯</span>
                </div>
                <h4 className="text-xl font-semibold mb-2">Microservices</h4>
                <p className="text-gray-600">10+ services with clear boundaries and domain-driven design</p>
              </div>
              <div className="text-center">
                <div className="w-16 h-16 bg-green-100 rounded-lg mx-auto mb-4 flex items-center justify-center">
                  <span className="text-2xl">⚡</span>
                </div>
                <h4 className="text-xl font-semibold mb-2">Event Streaming</h4>
                <p className="text-gray-600">EventBridge and Kinesis for real-time data flow</p>
              </div>
              <div className="text-center">
                <div className="w-16 h-16 bg-purple-100 rounded-lg mx-auto mb-4 flex items-center justify-center">
                  <span className="text-2xl">🔍</span>
                </div>
                <h4 className="text-xl font-semibold mb-2">Observability</h4>
                <p className="text-gray-600">Full tracing with ADOT, X-Ray, and CloudWatch</p>
              </div>
            </div>
          </div>
        </section>

        <section id="architecture" className="py-16">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <h3 className="text-3xl font-bold text-center mb-12">Architecture Overview</h3>
            <div className="bg-white p-8 rounded-lg shadow-md">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div>
                  <h4 className="text-xl font-semibold mb-4">Backend Services</h4>
                  <ul className="space-y-2 text-gray-600">
                    <li>✓ Identity Service - AWS Cognito</li>
                    <li>✓ Catalog Service - PostgreSQL</li>
                    <li>✓ Orders Service - Step Functions</li>
                    <li>✓ Search Service - OpenSearch</li>
                    <li>✓ Feed Service - GraphQL API</li>
                  </ul>
                </div>
                <div>
                  <h4 className="text-xl font-semibold mb-4">Infrastructure</h4>
                  <ul className="space-y-2 text-gray-600">
                    <li>✓ EKS for container orchestration</li>
                    <li>✓ ArgoCD for GitOps</li>
                    <li>✓ Terraform for IaC</li>
                    <li>✓ CloudFront CDN</li>
                    <li>✓ Multi-AZ deployment</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section className="py-16 bg-gray-900 text-white">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <h3 className="text-3xl font-bold mb-4">Ready to Deploy?</h3>
            <p className="text-lg mb-8">
              Clone the repository and follow our comprehensive deployment guide
            </p>
            <a 
              href="https://github.com/mofekayode/Shopstream" 
              className="inline-block px-8 py-3 bg-white text-gray-900 rounded-lg hover:bg-gray-100"
            >
              Get Started on GitHub
            </a>
          </div>
        </section>
      </main>

      <footer className="bg-white py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center text-gray-600">
            <p>© 2025 Shopstream - Reference Architecture</p>
            <p className="mt-2">Built with Next.js, TypeScript, and AWS</p>
          </div>
        </div>
      </footer>
    </div>
  );
}