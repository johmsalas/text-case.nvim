import StepOne from './components/step-one';

const SampleWizard = () => {
  const [currentStep, setCurrentStep] = useState(1)
  if (currentStep === steps.STEP_ONE) {
    return <StepOne />
  }
}
