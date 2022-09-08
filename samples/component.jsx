import StepOne from './components/step-one';

const SampleWizard = ({ var1, var2 }) => {
  console.log({ var2 })
  const [currentStep, setCurrentStep] = useState(1)
  if (currentStep === steps.STEP_ONE) {
    return <StepOne />
  }
}
