const UsageChart = {
  mounted() {
    this.renderChart()
  },

  updated() {
    this.chart.destroy()
    this.renderChart()
  },

  renderChart() {
    const ctx = this.el.getContext("2d")

    const labels = JSON.parse(this.el.dataset.labels)
    const values = JSON.parse(this.el.dataset.values)
    const fullKeys = JSON.parse(this.el.dataset.fullkeys)

    this.chart = new Chart(ctx, {
      type: "bar",
      data: {
        labels: labels,
        datasets: [{
          label: "API Calls",
          data: values,
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: { display: false },

          tooltip: {
            callbacks: {
              title: (tooltipItems) => {
                const index = tooltipItems[0].dataIndex
                return `API Key: ${fullKeys[index]}`
              },
              label: (tooltipItem) => {
                return `Calls: ${tooltipItem.raw}`
              }
            }
          }
        },
        scales: {
          x: {
            ticks: {
              color: "#9CA3AF",
              maxRotation: 45,
              minRotation: 45
            },
            grid: { display: false }
          },
          y: {
            ticks: { color: "#9CA3AF" },
            grid: { color: "rgba(255,255,255,0.05)" }
          }
        }
      }
    })
  }
}

export default UsageChart
